import 'package:flutter/material.dart';
import 'package:cred_assignment/app/data/models/bill_card_model.dart';
import 'package:cred_assignment/app/utils/app_colors.dart';
import 'package:cred_assignment/app/utils/common_widgets.dart';
import 'flipper_text.dart';

/// A single bill card widget matching the CRED design.
///
/// Displays: logo, title, subtitle, payment button, and footer/flipper text.
class BillCard extends StatelessWidget {
  final BillCardModel card;

  const BillCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          if (card.logo != null)
            LogoAvatar(
              imageUrl: card.logo!.url,
              bgColor: card.logo!.bgColor,
            ),
          const SizedBox(width: 12),

          // Title, subtitle
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
                ),
                const SizedBox(height: 2),
                Text(
                  card.subTitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Right side: Pay button + tag
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pay CTA button
              if (card.primaryCta != null)
                PayButton(title: card.primaryCta!.title),
              const SizedBox(height: 6),

              // Flipper tag or static footer
              FlipperText(
                flipperConfig: card.flipperConfig,
                footerText: card.footerText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
