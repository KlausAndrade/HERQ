import 'dart:math';
import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/models/analytics_models.dart';

/// Service for calculating advanced analytics and PR predictions
class AnalyticsService {
  AnalyticsService(this.database);
  final AppDatabase database;

  /// Get comprehensive analytics for user
  Future<AnalyticsData> getAnalytics() async {
    final powerScore = await calculatePowerScore();
    final prStreaks = await calculatePRStreaks();
    final nearMisses = await findNearMissPRs();
    final predictions = await predictFuturePRs();
    final volumeTrends = await analyzeVolumeTrends();
    final exerciseProgress = await getExerciseProgress();
    final plateauAnalysis = await detectPlateaus();
    final strengthBalance = await analyzeStrengthBalance();

    return AnalyticsData(
      powerScore: powerScore,
      prStreaks: prStreaks,
      nearMisses: nearMisses,
      predictions: predictions,
      volumeTrends: volumeTrends,
      exerciseProgress: exerciseProgress,
      plateauAnalysis: plateauAnalysis,
      strengthBalance: strengthBalance,
    );
  }

  /// Calculate user's overall power score
  Future<PowerScore> calculatePowerScore({String? userId}) async {
    // Get all PRs from last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final recentPRs = await (database.select(database.personalRecords)
          ..where((pr) => pr.achievedAt.isBiggerOrEqualValue(thirtyDaysAgo)))
        .get();

    // Calculate power score based on:
    // - Number of PRs
    // - Total volume moved
    // - Frequency of training
    // - Consistency

    final allPRs = await database.select(database.personalRecords).get();

    double current = 0;

    // Weight PRs contribute more
    for (final pr in allPRs) {
      if (pr.recordType == 'reps' || pr.recordType == '1rm') {
        current += (pr.weight ?? 0) * (pr.reps ?? 1) * 0.5; // Weight x Reps
      }
    }

    // Scale to reasonable numbers
    current = (current / 100).roundToDouble();

    // Calculate 30-day change
    final thirtyDayScore = recentPRs.fold<double>(
          0,
          (sum, pr) => sum + (pr.weight ?? 0) * (pr.reps ?? 1) * 0.5,
        ) /
        100;

    // Determine tier based on score
    String tier;
    int pointsToNext;

    if (current < 50) {
      tier = 'Bronze';
      pointsToNext = (50 - current).round();
    } else if (current < 150) {
      tier = 'Silver';
      pointsToNext = (150 - current).round();
    } else if (current < 300) {
      tier = 'Gold';
      pointsToNext = (300 - current).round();
    } else if (current < 500) {
      tier = 'Platinum';
      pointsToNext = (500 - current).round();
    } else {
      tier = 'Diamond';
      pointsToNext = 0;
    }

    // If userId provided, calculate rank across all users using user_stats table
    int rank = 0;
    if (userId != null) {
      // Order users by total_volume desc and find the position of this user
      final rows = await database.customSelect(
        'SELECT user_id FROM user_stats ORDER BY total_volume DESC',
        readsFrom: {database.userStats},
      ).get();

      for (var i = 0; i < rows.length; i++) {
        final uid = rows[i].read<String>('user_id');
        if (uid == userId) {
          rank = i + 1; // 1-based rank
          break;
        }
      }
    }

    return PowerScore(
      current: current,
      change30Days: thirtyDayScore,
      changeAllTime: current,
      rank: rank,
      tier: tier,
      pointsToNextTier: pointsToNext,
    );
  }

  /// Calculate PR streaks for exercises
  Future<List<PRStreak>> calculatePRStreaks() async {
    final exercises = await database.select(database.exercises).get();
    final streaks = <PRStreak>[];

    for (final exercise in exercises) {
      // Get all PRs for this exercise, ordered by date
      final prs = await (database.select(database.personalRecords)
            ..where((pr) => pr.exerciseId.equals(exercise.id))
            ..orderBy([(pr) => OrderingTerm.desc(pr.achievedAt)]))
          .get();

      if (prs.isEmpty) continue;

      // Calculate current streak
      int currentStreak = 0;
      int longestStreak = 0;
      int tempStreak = 0;

      final DateTime? lastPRDate = prs.isNotEmpty ? prs.first.achievedAt : null;

      // PRs are in descending order (newest first)
      for (var i = 0; i < prs.length; i++) {
        final pr = prs[i];

        if (i == 0) {
          // First (most recent) PR
          tempStreak = 1;
          currentStreak = 1;
        } else {
          final daysBetween =
              prs[i - 1].achievedAt.difference(pr.achievedAt).inDays;

          // If PRs are within 14 days of each other, streak continues
          if (daysBetween <= 14) {
            tempStreak++;
            if (i < 3) {
              currentStreak++; // Only count recent ones for current streak
            }
          } else {
            longestStreak = max(longestStreak, tempStreak);
            tempStreak = 1;
          }
        }
      }

      longestStreak = max(longestStreak, tempStreak);

      // Check if streak is still active (last PR within 14 days)
      if (lastPRDate != null) {
        final daysSinceLastPR = DateTime.now().difference(lastPRDate).inDays;
        if (daysSinceLastPR > 14) {
          currentStreak = 0;
        }
      }

      if (longestStreak > 0) {
        streaks.add(
          PRStreak(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastPRDate: lastPRDate,
            nextPossiblePR: lastPRDate?.add(const Duration(days: 7)),
          ),
        );
      }
    }

    // Sort by current streak (active streaks first)
    streaks.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

    return streaks;
  }

  /// Find near-miss PRs to motivate users
  Future<List<NearMissPR>> findNearMissPRs() async {
    final nearMisses = <NearMissPR>[];
    final exercises = await database.select(database.exercises).get();

    for (final exercise in exercises) {
      // Get current PR
      final currentPR = await (database.select(database.personalRecords)
            ..where((pr) => pr.exerciseId.equals(exercise.id))
            ..orderBy([(pr) => OrderingTerm.desc(pr.weight)])
            ..limit(1))
          .getSingleOrNull();

      if (currentPR == null) continue;

      // Get recent attempts (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final recentSets = await database.customSelect(
        '''
        SELECT se.*, ws.completed_at
        FROM set_entries se
        JOIN workout_sessions ws ON se.workout_session_id = ws.id
        WHERE se.exercise_id = ? AND ws.completed_at >= ? AND se.completed_at IS NOT NULL
        ORDER BY se.weight DESC, se.reps DESC
        LIMIT 10
        ''',
        variables: [
          Variable.withString(exercise.id),
          Variable.withDateTime(thirtyDaysAgo),
        ],
        readsFrom: {database.setEntries, database.workoutSessions},
      ).get();

      for (final row in recentSets) {
        final weight = row.read<double?>('weight');
        final reps = row.read<int>('reps');
        final completedAt = row.read<DateTime>('completed_at');

        // Skip sets without weight (e.g., bodyweight exercises)
        if (weight == null) continue;

        // Calculate 1RM equivalent
        final attempt1RM = weight * (1 + reps / 30);
        final pr1RM =
            (currentPR.weight ?? 0) * (1 + (currentPR.reps ?? 1) / 30);

        // Check if it's a near miss (85-99% of current PR)
        final percentage = (attempt1RM / pr1RM) * 100;

        if (percentage >= 85 && percentage < 100) {
          String message;
          if (percentage >= 95) {
            message =
                '🔥 SO CLOSE! Just ${(currentPR.weight! - weight).toStringAsFixed(1)}kg away from a PR!';
          } else if (percentage >= 90) {
            message = '💪 Almost there! You\'re getting stronger every day!';
          } else {
            message = '📈 Great progress! Keep pushing, PR incoming!';
          }

          nearMisses.add(
            NearMissPR(
              exerciseId: exercise.id,
              exerciseName: exercise.name,
              currentBest: currentPR.weight ?? 0,
              attemptedWeight: weight,
              attemptedReps: reps,
              percentageClose: percentage,
              attemptDate: completedAt,
              motivationalMessage: message,
            ),
          );
          break; // Only one near miss per exercise
        }
      }
    }

    // Sort by how close they were
    nearMisses.sort((a, b) => b.percentageClose.compareTo(a.percentageClose));

    return nearMisses.take(5).toList();
  }

  /// Predict future PRs using trend analysis
  Future<List<PRPrediction>> predictFuturePRs() async {
    final predictions = <PRPrediction>[];
    final exercises = await database.select(database.exercises).get();

    for (final exercise in exercises) {
      // Get PR history for this exercise
      final prs = await (database.select(database.personalRecords)
            ..where((pr) => pr.exerciseId.equals(exercise.id))
            ..orderBy([(pr) => OrderingTerm.asc(pr.achievedAt)]))
          .get();

      if (prs.length < 3) continue; // Need at least 3 PRs to predict

      // Skip exercises without weight data (bodyweight/duration exercises)
      if (prs.every((pr) => pr.weight == null || pr.weight == 0)) continue;

      // Calculate linear regression for weight progression
      final dataPoints =
          prs.where((pr) => pr.weight != null && pr.weight! > 0).map((pr) {
        final daysSinceFirst =
            pr.achievedAt.difference(prs.first.achievedAt).inDays;
        return {
          'x': daysSinceFirst.toDouble(),
          'y': pr.weight!.toDouble(),
        };
      }).toList();

      // Need at least 3 valid data points
      if (dataPoints.length < 3) continue;

      final regression = _calculateLinearRegression(dataPoints);

      // Skip if regression calculation failed or invalid
      if (regression['slope'] == null ||
          regression['slope']!.isNaN ||
          regression['slope']!.isInfinite ||
          regression['slope']! <= 0) {
        continue; // Not progressing or invalid data
      }

      // Predict next PR (assume in 30 days)
      final lastPR = prs.last;
      final daysSinceStart =
          DateTime.now().difference(prs.first.achievedAt).inDays;
      const daysToPredict = 30;
      final predictedX = daysSinceStart + daysToPredict;

      final predictedWeight =
          regression['slope']! * predictedX + regression['intercept']!;
      final currentWeight = lastPR.weight ?? 0;

      // Skip if prediction is invalid
      if (predictedWeight.isNaN ||
          predictedWeight.isInfinite ||
          predictedWeight <= 0 ||
          currentWeight <= 0) {
        continue;
      }

      // Only predict if there's expected improvement
      if (predictedWeight <= currentWeight) continue;

      // Calculate confidence based on R² (how well data fits the line)
      final rSquared = regression['rSquared']!;
      final confidence =
          (rSquared * 100).clamp(0, 95).toDouble(); // Max 95% confidence

      // Generate recommendations
      final recommendations = _generatePRRecommendations(
        exercise.name,
        currentWeight,
        predictedWeight,
        regression['slope']!,
      );

      predictions.add(
        PRPrediction(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          currentPR: currentWeight,
          predictedPR: predictedWeight,
          predictedDate:
              DateTime.now().add(const Duration(days: daysToPredict)),
          confidence: confidence,
          reasoning:
              'Based on your consistent ${regression['slope']!.toStringAsFixed(2)}kg/week progress',
          recommendations: recommendations,
        ),
      );
    }

    // Sort by confidence
    predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

    return predictions.take(5).toList();
  }

  /// Calculate linear regression for trend analysis
  Map<String, double> _calculateLinearRegression(
    List<Map<String, double>> data,
  ) {
    final n = data.length.toDouble();
    final sumX = data.fold<double>(0, (sum, point) => sum + point['x']!);
    final sumY = data.fold<double>(0, (sum, point) => sum + point['y']!);
    final sumXY =
        data.fold<double>(0, (sum, point) => sum + point['x']! * point['y']!);
    final sumX2 =
        data.fold<double>(0, (sum, point) => sum + point['x']! * point['x']!);

    final denominator = n * sumX2 - sumX * sumX;

    // Prevent division by zero
    if (denominator == 0 || denominator.isNaN) {
      return {
        'slope': 0.0,
        'intercept': 0.0,
        'rSquared': 0.0,
      };
    }

    final slope = (n * sumXY - sumX * sumY) / denominator;
    final intercept = (sumY - slope * sumX) / n;

    // Check for invalid values
    if (slope.isNaN ||
        slope.isInfinite ||
        intercept.isNaN ||
        intercept.isInfinite) {
      return {
        'slope': 0.0,
        'intercept': 0.0,
        'rSquared': 0.0,
      };
    }

    // Calculate R² (coefficient of determination)
    final yMean = sumY / n;
    final ssTotal =
        data.fold<double>(0, (sum, point) => sum + pow(point['y']! - yMean, 2));

    // Prevent division by zero in R² calculation
    if (ssTotal == 0 || ssTotal.isNaN) {
      return {
        'slope': slope / 7, // Convert to weekly gain
        'intercept': intercept,
        'rSquared': 0.0,
      };
    }

    final ssResidual = data.fold<double>(0, (sum, point) {
      final predicted = slope * point['x']! + intercept;
      return sum + pow(point['y']! - predicted, 2);
    });
    final rSquared = 1 - (ssResidual / ssTotal);

    return {
      'slope': slope / 7, // Convert to weekly gain
      'intercept': intercept,
      'rSquared': rSquared.clamp(0, 1),
    };
  }

  /// Generate personalized recommendations for PR attempts
  List<String> _generatePRRecommendations(
    String exerciseName,
    double currentWeight,
    double predictedWeight,
    double weeklyGain,
  ) {
    final recommendations = <String>[];
    final gain = predictedWeight - currentWeight;

    recommendations.add(
      '💡 Try adding ${(gain / 2).toStringAsFixed(1)}kg in your next workout',
    );
    recommendations.add(
      '🎯 Aim for ${(currentWeight + weeklyGain).toStringAsFixed(1)}kg this week',
    );

    if (weeklyGain < 1) {
      recommendations
          .add('📈 Consider a deload week to reset for bigger gains');
    } else {
      recommendations.add('🔥 You\'re on fire! Maintain this momentum');
    }

    return recommendations;
  }

  /// Analyze volume trends
  Future<List<VolumeAnalysis>> analyzeVolumeTrends() async {
    final trends = <VolumeAnalysis>[];
    final now = DateTime.now();

    // Get last 12 weeks of data
    for (var i = 11; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: 7 * (i + 1)));
      final weekEnd = now.subtract(Duration(days: 7 * i));

      // Calculate total volume for this week
      final volumeData = await database.customSelect(
        '''
        SELECT 
          e.primary_muscle_group,
          SUM(se.weight * se.reps) as volume
        FROM set_entries se
        JOIN workout_sessions ws ON se.workout_session_id = ws.id
        JOIN exercises e ON se.exercise_id = e.id
        WHERE ws.completed_at >= ? AND ws.completed_at < ? AND se.completed_at IS NOT NULL
        GROUP BY e.primary_muscle_group
        ''',
        variables: [
          Variable.withDateTime(weekStart),
          Variable.withDateTime(weekEnd),
        ],
        readsFrom: {
          database.setEntries,
          database.workoutSessions,
          database.exercises,
        },
      ).get();

      final volumeByMuscle = <String, double>{};
      double totalVolume = 0;

      for (final row in volumeData) {
        final muscleGroup =
            row.read<String?>('primary_muscle_group') ?? 'Unknown';
        final volume = row.read<double?>('volume') ?? 0;
        volumeByMuscle[muscleGroup] = volume;
        totalVolume += volume;
      }

      // Calculate change from previous week
      double change = 0;
      if (i < 11 && trends.isNotEmpty) {
        final prevVolume = trends.last.totalVolume;
        change = ((totalVolume - prevVolume) / prevVolume) * 100;
      }

      trends.add(
        VolumeAnalysis(
          date: weekEnd,
          period: 'week',
          totalVolume: totalVolume,
          volumeByMuscleGroup: volumeByMuscle,
          change: change,
          isIncreasing: change > 0,
        ),
      );
    }

    return trends;
  }

  /// Get detailed progress for each exercise
  Future<List<ExerciseProgress>> getExerciseProgress() async {
    final exercises = await database.select(database.exercises).get();
    final progressList = <ExerciseProgress>[];

    for (final exercise in exercises) {
      // Get all sets for this exercise
      final sets = await database.customSelect(
        '''
        SELECT se.*, ws.completed_at
        FROM set_entries se
        JOIN workout_sessions ws ON se.workout_session_id = ws.id
        WHERE se.exercise_id = ? AND se.completed_at IS NOT NULL
        ORDER BY ws.completed_at ASC
        ''',
        variables: [Variable.withString(exercise.id)],
        readsFrom: {database.setEntries, database.workoutSessions},
      ).get();

      if (sets.isEmpty) continue;

      final firstSet = sets.first;
      final lastSet = sets.last;

      final startWeight = firstSet.read<double?>('weight');
      final currentWeight = lastSet.read<double?>('weight');

      // Skip exercises without weight data (e.g., bodyweight exercises)
      if (startWeight == null || currentWeight == null || startWeight == 0) {
        continue;
      }

      final totalGain = currentWeight - startWeight;
      final percentageGain = (totalGain / startWeight) * 100;

      // Get personal records for this exercise to mark PRs in history
      final prsForExercise = await (database.select(database.personalRecords)
            ..where((pr) => pr.exerciseId.equals(exercise.id)))
          .get();

      // Build history and mark PRs when a set matches a personal record
      final history = sets.map((row) {
        final setDate = row.read<DateTime>('completed_at');
        final setWeight = row.read<double?>('weight') ?? 0.0;
        final setReps = row.read<int>('reps');

        // Tolerances to account for small precision differences
        const weightTolerance = 0.25; // kg
        const timeToleranceSeconds = 2;

        final bool isPR = prsForExercise.any((pr) {
          final prWeight = pr.weight ?? 0;
          final prReps = pr.reps ?? 0;
          final prDate = pr.achievedAt;

          final weightMatches = (prWeight - setWeight).abs() <= weightTolerance;
          final repsMatches = prReps == setReps;
          final timeMatches = prDate.difference(setDate).inSeconds.abs() <=
              timeToleranceSeconds;

          return weightMatches && repsMatches && timeMatches;
        });

        return ProgressDataPoint(
          date: setDate,
          weight: setWeight,
          reps: setReps,
          isPR: isPR,
        );
      }).toList();

      // Determine trend
      TrendDirection trend;
      if (sets.length >= 3) {
        final recent = sets.sublist(max(0, sets.length - 5));
        final weights = recent
            .map((r) => r.read<double?>('weight') ?? 0.0)
            .where((w) => w > 0)
            .toList();

        // Skip trend calculation if no valid weights
        if (weights.isEmpty) {
          trend = TrendDirection.stable;
        } else {
          final avgRecent = weights.reduce((a, b) => a + b) / weights.length;

          if (avgRecent > currentWeight * 0.95) {
            trend = TrendDirection.increasing;
          } else if (avgRecent > currentWeight * 0.90) {
            trend = TrendDirection.stable;
          } else {
            trend = TrendDirection.decreasing;
          }
        }
      } else {
        trend = TrendDirection.stable;
      }

      progressList.add(
        ExerciseProgress(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          startWeight: startWeight,
          currentWeight: currentWeight,
          totalGain: totalGain,
          percentageGain: percentageGain,
          workoutCount: sets.length,
          firstWorkout: firstSet.read<DateTime>('completed_at'),
          lastWorkout: lastSet.read<DateTime>('completed_at'),
          trend: trend,
          history: history,
        ),
      );
    }

    // Sort by total gain
    progressList.sort((a, b) => b.totalGain.compareTo(a.totalGain));

    return progressList;
  }

  /// Detect exercises in plateau
  Future<PlateauAnalysis> detectPlateaus() async {
    final plateaus = <PlateauDetection>[];
    final exercises = await database.select(database.exercises).get();

    for (final exercise in exercises) {
      // Get last PR date
      final lastPR = await (database.select(database.personalRecords)
            ..where((pr) => pr.exerciseId.equals(exercise.id))
            ..orderBy([(pr) => OrderingTerm.desc(pr.achievedAt)])
            ..limit(1))
          .getSingleOrNull();

      if (lastPR == null) continue;

      final weeksSinceLastPR =
          DateTime.now().difference(lastPR.achievedAt).inDays ~/ 7;

      if (weeksSinceLastPR >= 4) {
        PlateauSeverity severity;
        if (weeksSinceLastPR >= 8) {
          severity = PlateauSeverity.severe;
        } else if (weeksSinceLastPR >= 6) {
          severity = PlateauSeverity.moderate;
        } else {
          severity = PlateauSeverity.mild;
        }

        plateaus.add(
          PlateauDetection(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            weeksStagnant: weeksSinceLastPR,
            currentWeight: lastPR.weight ?? 0,
            startDate: lastPR.achievedAt,
            severity: severity,
            recommendations:
                _getPlateauRecommendations(severity, exercise.name),
          ),
        );
      }
    }

    // Get last time any plateau was broken
    final allPRs = await (database.select(database.personalRecords)
          ..orderBy([(pr) => OrderingTerm.desc(pr.achievedAt)]))
        .get();

    DateTime? lastPlateauBroken;
    if (allPRs.isNotEmpty) {
      lastPlateauBroken = allPRs.first.achievedAt;
    }

    return PlateauAnalysis(
      plateaus: plateaus,
      totalPlateaus: plateaus.length,
      lastPlateauBroken: lastPlateauBroken,
    );
  }

  List<String> _getPlateauRecommendations(
    PlateauSeverity severity,
    String exerciseName,
  ) {
    switch (severity) {
      case PlateauSeverity.severe:
        return [
          '🔄 Consider a full deload week (50% volume)',
          '📝 Try a different exercise variation',
          '💪 Focus on progressive overload with reps first',
        ];
      case PlateauSeverity.moderate:
        return [
          '⚡ Increase training frequency for $exerciseName',
          '📊 Track your nutrition and sleep',
          '🎯 Add variation sets (pause reps, tempo changes)',
        ];
      case PlateauSeverity.mild:
        return [
          '💡 Small weight jumps (1-2kg) instead of 5kg',
          '🔥 Add an extra set to build volume',
          '⏱️ Ensure you\'re fully rested between sets',
        ];
    }
  }

  /// Analyze muscle group balance
  Future<StrengthBalance> analyzeStrengthBalance() async {
    // Get volume distribution by muscle group over last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final volumeData = await database.customSelect(
      '''
      SELECT 
        e.primary_muscle_group,
        SUM(se.weight * se.reps) as total_volume
      FROM set_entries se
      JOIN workout_sessions ws ON se.workout_session_id = ws.id
      JOIN exercises e ON se.exercise_id = e.id
      WHERE ws.completed_at >= ? AND se.completed_at IS NOT NULL
      GROUP BY e.primary_muscle_group
      ''',
      variables: [Variable.withDateTime(thirtyDaysAgo)],
      readsFrom: {
        database.setEntries,
        database.workoutSessions,
        database.exercises,
      },
    ).get();

    final volumeByMuscle = <String, double>{};
    double totalVolume = 0;

    for (final row in volumeData) {
      final muscleGroup =
          row.read<String?>('primary_muscle_group') ?? 'Unknown';
      final volume = row.read<double?>('total_volume') ?? 0;
      volumeByMuscle[muscleGroup] = volume;
      totalVolume += volume;
    }

    // Calculate percentages
    final distribution = volumeByMuscle.map(
      (muscle, volume) => MapEntry(muscle, (volume / totalVolume) * 100),
    );

    // Ideal distribution (rough guidelines)
    final idealDistribution = {
      'chest': 15.0,
      'back': 20.0,
      'shoulders': 12.0,
      'legs': 25.0,
      'arms': 15.0,
      'core': 13.0,
    };

    // Calculate imbalances
    final imbalances = <MuscleGroupBalance>[];
    for (final entry in distribution.entries) {
      final ideal = idealDistribution[entry.key.toLowerCase()] ?? 15.0;
      final diff = entry.value - ideal;

      BalanceStatus status;
      if (diff < -10) {
        status = BalanceStatus.undertrained;
      } else if (diff > 10) {
        status = BalanceStatus.overtrained;
      } else {
        status = BalanceStatus.balanced;
      }

      imbalances.add(
        MuscleGroupBalance(
          muscleGroup: entry.key,
          currentPercentage: entry.value,
          idealPercentage: ideal,
          difference: diff,
          status: status,
        ),
      );
    }

    // Calculate overall balance score
    final balanceScore = (100 -
            imbalances.fold<double>(
              0,
              (sum, imb) => sum + imb.difference.abs(),
            ))
        .clamp(0, 100)
        .toDouble();

    final recommendations = _getBalanceRecommendations(imbalances);

    return StrengthBalance(
      volumeDistribution: distribution,
      imbalances: imbalances,
      balanceScore: balanceScore,
      recommendations: recommendations,
    );
  }

  List<String> _getBalanceRecommendations(List<MuscleGroupBalance> imbalances) {
    final recommendations = <String>[];

    for (final imbalance in imbalances) {
      if (imbalance.status == BalanceStatus.undertrained &&
          imbalance.difference.abs() > 10) {
        recommendations.add(
          '🎯 Increase ${imbalance.muscleGroup} training by ${imbalance.difference.abs().round()}%',
        );
      }
      if (imbalance.status == BalanceStatus.overtrained &&
          imbalance.difference.abs() > 10) {
        recommendations.add(
          '⚠️ Reduce ${imbalance.muscleGroup} volume slightly to prevent overtraining',
        );
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('✅ Your training is well balanced! Keep it up!');
    }

    return recommendations;
  }
}
