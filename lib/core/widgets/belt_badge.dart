import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class BeltBadge extends StatelessWidget {
  final BeltRank beltRank;
  final bool showLabel;
  final double size;

  const BeltBadge({
    super.key,
    required this.beltRank,
    this.showLabel = true,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = beltRank.primaryColor;
    final stripColor = beltRank.stripColor;

    final dotWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: beltRank == BeltRank.putih
              ? AppColors.outlineVariant
              : primaryColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: stripColor != null
          ? Center(
              child: Container(
                width: size * 0.35,
                height: size,
                color: stripColor,
              ),
            )
          : null,
    );

    if (!showLabel) return dotWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dotWidget,
        const SizedBox(width: 6),
        Text(
          beltRank.displayName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class BeltPill extends StatelessWidget {
  final BeltRank beltRank;

  const BeltPill({super.key, required this.beltRank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: BeltBadge(beltRank: beltRank, showLabel: true, size: 10),
    );
  }
}

