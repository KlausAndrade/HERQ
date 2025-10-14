import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../theme/app_animations.dart';
import '../theme/app_theme.dart';

/// Skeleton loader for workout cards
class WorkoutCardSkeleton extends StatelessWidget {
  const WorkoutCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ShimmerLoading(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSM),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 150,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSM),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

/// Skeleton loader for quick action cards
class QuickActionCardSkeleton extends StatelessWidget {
  const QuickActionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ShimmerLoading(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Container(
                  width: 130,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Skeleton loader for exercise list items
class ExerciseListItemSkeleton extends StatelessWidget {
  const ExerciseListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ShimmerLoading(
        child: Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
            ),
            title: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
            ),
            subtitle: Container(
              height: 12,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
            ),
          ),
        ),
      );
}

/// Skeleton loader for stats row
class StatsRowSkeleton extends StatelessWidget {
  const StatsRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ShimmerLoading(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            3,
            (index) => Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Generic skeleton container
class SkeletonContainer extends StatelessWidget {
  const SkeletonContainer({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => ShimmerLoading(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppTheme.radiusSM),
          ),
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties
        .add(DiagnosticsProperty<BorderRadius?>('borderRadius', borderRadius));
  }
}

/// Skeleton loader for a list of items
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    required this.itemBuilder,
    super.key,
    this.itemCount = 3,
    this.separator,
  });

  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final Widget? separator;

  @override
  Widget build(BuildContext context) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) =>
            separator ?? const SizedBox(height: AppTheme.spacingSM),
        itemBuilder: itemBuilder,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<
        Widget Function(
            BuildContext context, int index)>.has('itemBuilder', itemBuilder));
    properties.add(IntProperty('itemCount', itemCount));
  }
}
