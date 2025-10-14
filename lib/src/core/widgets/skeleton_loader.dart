import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_animations.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    required this.child,
    this.isLoading = true,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final bool isLoading;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return ShimmerLoading(
      duration: duration,
      child: child,
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius,
    this.child,
  });

  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SkeletonLoader(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[300],
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppTheme.radiusMD),
        ),
        child: child,
      ),
    );
  }
}

class SkeletonText extends StatelessWidget {
  const SkeletonText({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = 4,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SkeletonLoader(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[300],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  const SkeletonAvatar({
    super.key,
    this.size = 40,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SkeletonLoader(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[300],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
    super.key,
    this.hasAvatar = true,
    this.hasSubtitle = true,
    this.hasTrailing = false,
  });

  final bool hasAvatar;
  final bool hasSubtitle;
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      child: Row(
        children: [
          if (hasAvatar) ...[
            const SkeletonAvatar(),
            const SizedBox(width: AppTheme.spacingMD),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonText(width: 200),
                if (hasSubtitle) ...[
                  const SizedBox(height: AppTheme.spacingSM),
                  const SkeletonText(width: 150, height: 12),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: AppTheme.spacingMD),
            const SkeletonText(width: 60, height: 12),
          ],
        ],
      ),
    );
  }
}

class SkeletonWorkoutCard extends StatelessWidget {
  const SkeletonWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
      child: SkeletonCard(
        height: 140,
        child: const Padding(
          padding: EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonText(width: 120, height: 18),
              SizedBox(height: AppTheme.spacingSM),
              SkeletonText(width: 200, height: 14),
              SizedBox(height: AppTheme.spacingSM),
              SkeletonText(width: 80, height: 12),
              Spacer(),
              Row(
                children: [
                  SkeletonText(width: 60, height: 12),
                  SizedBox(width: AppTheme.spacingMD),
                  SkeletonText(width: 40, height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
