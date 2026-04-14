/// Premium Stats Card - Advanced Data Display Component
/// Professional statistics card with animations, progress bars, and gradients

import 'package:flutter/material.dart';
import '../core/design/premium_colors.dart';
import '../core/design/premium_typography.dart';
import 'premium_glass_card.dart';

class PremiumStatsCard extends StatefulWidget {
  final String title;
  final String value;
  final String? unit;
  final String? subtitle;
  final Color accentColor;
  final Widget? icon;
  final LinearGradient? gradient;
  final double? progressValue; // 0-1
  final bool isAnimated;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue; // positive or negative
  final String? trendLabel;

  const PremiumStatsCard({
    Key? key,
    required this.title,
    required this.value,
    this.unit,
    this.subtitle,
    required this.accentColor,
    this.icon,
    this.gradient,
    this.progressValue,
    this.isAnimated = true,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.trendLabel,
  }) : super(key: key);

  @override
  State<PremiumStatsCard> createState() => _PremiumStatsCardState();
}

class _PremiumStatsCardState extends State<PremiumStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimated) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );

      _slideAnimation =
          Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );

      _progressAnimation = Tween<double>(begin: 0, end: widget.progressValue ?? 0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _animationController.forward();
    }
  }

  @override
  void dispose() {
    if (widget.isAnimated) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // Header Row: Icon + Title + Trend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    widget.title,
                    style: PremiumTypography.bodyMedium.copyWith(
                      color: PremiumColors.textSecondary,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    spacing: 6,
                    children: [
                      Text(
                        widget.value,
                        style: PremiumTypography.headlineLarge.copyWith(
                          color: PremiumColors.textPrimary,
                        ),
                      ),
                      if (widget.unit != null)
                        Text(
                          widget.unit!,
                          style: PremiumTypography.bodyLarge.copyWith(
                            color: PremiumColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: PremiumTypography.bodySmall.copyWith(
                        color: PremiumColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.icon != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.accentColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: IconTheme(
                  data: IconThemeData(color: widget.accentColor, size: 24),
                  child: widget.icon!,
                ),
              ),
          ],
        ),

        // Trend Indicator
        if (widget.showTrend && widget.trendValue != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (widget.trendValue! > 0 ? PremiumColors.success : PremiumColors.error)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Icon(
                  widget.trendValue! > 0 ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: widget.trendValue! > 0 ? PremiumColors.success : PremiumColors.error,
                ),
                Text(
                  '${widget.trendValue!.toStringAsFixed(1)}%',
                  style: PremiumTypography.labelSmall.copyWith(
                    color: widget.trendValue! > 0 ? PremiumColors.success : PremiumColors.error,
                  ),
                ),
                if (widget.trendLabel != null)
                  Text(
                    widget.trendLabel!,
                    style: PremiumTypography.bodySmall.copyWith(
                      color: PremiumColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),

        // Progress Bar
        if (widget.progressValue != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              if (widget.isAnimated)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progressAnimation.value,
                        minHeight: 6,
                        backgroundColor: PremiumColors.darkLuxuryLighter,
                        valueColor: AlwaysStoppedAnimation(widget.accentColor),
                      ),
                    );
                  },
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: widget.progressValue!,
                    minHeight: 6,
                    backgroundColor: PremiumColors.darkLuxuryLighter,
                    valueColor: AlwaysStoppedAnimation(widget.accentColor),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(widget.progressValue! * 100).toStringAsFixed(0)}%',
                    style: PremiumTypography.labelSmall.copyWith(
                      color: PremiumColors.textTertiary,
                    ),
                  ),
                  Text(
                    '100%',
                    style: PremiumTypography.labelSmall.copyWith(
                      color: PremiumColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );

    if (widget.isAnimated) {
      content = FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: content,
        ),
      );
    }

    return PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      onTap: widget.onTap,
      child: content,
    );
  }
}
