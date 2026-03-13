import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Section header row: "UPCOMING BILLS (n)" + "view all >"
class SectionHeader extends StatelessWidget {
  final String title;
  final String billsCount;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    required this.billsCount,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.sectionTitle,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(letterSpacing: 1.2),
                ),
                const TextSpan(text: '( '),
                TextSpan(
                  text: billsCount.trim(),
                  style: const TextStyle(letterSpacing: 0),
                ),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: const Row(
              children: [
                Text(
                  'view all',
                  style: TextStyle(
                    color: AppColors.viewAllText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.viewAllText,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded logo avatar used inside bill cards.
class LogoAvatar extends StatelessWidget {
  final String imageUrl;
  final String bgColor;
  final double size;

  const LogoAvatar({
    super.key,
    required this.imageUrl,
    this.bgColor = '#ffffff',
    this.size = 40,
  });

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) buffer.write('FF');
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _parseColor(bgColor),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(6),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => const SizedBox.shrink(),
        errorWidget: (_, __, ___) => const Icon(
          Icons.account_balance,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Dark fixed-width "₹XXX" button (no "pay" prefix).
class PayButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const PayButton({
    super.key,
    required this.title,
    this.onTap,
  });

  /// Strips the "pay" prefix (case-insensitive) from the title.
  String get _amountOnly =>
      title.replaceAll(RegExp(r'^pay\s*', caseSensitive: false), '').trim();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.ctaBackground,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _amountOnly,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.ctaText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Full-screen loading indicator.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.ctaText,
        strokeWidth: 2,
      ),
    );
  }
}

/// Full-screen error state with retry.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.tagOverdue,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textOnDark,
                fontSize: 14,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ctaBackground,
                  foregroundColor: AppColors.ctaText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
