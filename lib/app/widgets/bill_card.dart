import 'package:flutter/material.dart';
import 'package:cred_assignment/app/data/models/bill_card_model.dart';
import 'package:cred_assignment/app/utils/app_colors.dart';
import 'package:cred_assignment/app/utils/common_widgets.dart';
import 'flipper_text.dart';

/// A single bill card row matching the CRED design.
///
/// Designed to sit inside the carousel container (no individual shadow).
/// Displays: logo, title, subtitle, payment button, and footer/flipper text.
class BillCard extends StatelessWidget {
  final BillCardModel card;

  const BillCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          if (card.logo != null)
            LogoAvatar(
              imageUrl: card.logo!.url,
              bgColor: card.logo!.bgColor,
            ),
          const SizedBox(width: 12),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  card.subTitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right side: Pay button + tag
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (card.primaryCta != null)
                  PayButton(title: card.primaryCta!.title),
                const SizedBox(height: 2),
                FlipperText(
                  flipperConfig: card.flipperConfig,
                  footerText: card.footerText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
