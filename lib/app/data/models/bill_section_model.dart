import 'bill_card_model.dart';

/// Model representing the top-level API response section.
class BillSectionModel {
  final String title;
  final String billsCount;
  final bool autoScrollEnabled;
  final CardsAnimationConfig? animationConfig;
  final List<BillCardModel> cards;
  final String? viewAllCtaTitle;

  BillSectionModel({
    required this.title,
    required this.billsCount,
    required this.autoScrollEnabled,
    this.animationConfig,
    required this.cards,
    this.viewAllCtaTitle,
  });

  factory BillSectionModel.fromJson(Map<String, dynamic> json) {
    final props = json['template_properties'] as Map<String, dynamic>;
    final body = props['body'] as Map<String, dynamic>;
    final childList = props['child_list'] as List<dynamic>? ?? [];
    final ctas = props['ctas'] as Map<String, dynamic>?;

    return BillSectionModel(
      title: body['title'] ?? '',
      billsCount: body['bills_count']?.toString() ?? '0',
      autoScrollEnabled: body['auto_scroll_enabled'] ?? false,
      animationConfig: body['cards_animation_config'] != null
          ? CardsAnimationConfig.fromJson(body['cards_animation_config'])
          : null,
      cards: childList
          .map((e) => BillCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      viewAllCtaTitle: ctas?['primary']?['title'],
    );
  }
}

/// Animation configuration for the card stack.
class CardsAnimationConfig {
  final int count;
  final int delay;
  final double duration;

  CardsAnimationConfig({
    required this.count,
    required this.delay,
    required this.duration,
  });

  factory CardsAnimationConfig.fromJson(Map<String, dynamic> json) {
    return CardsAnimationConfig(
      count: json['count'] ?? 10,
      delay: json['delay'] ?? 3,
      duration: double.tryParse(json['duration']?.toString() ?? '0.7') ?? 0.7,
    );
  }
}
