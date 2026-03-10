/// Model representing a single bill card from the API response.
class BillCardModel {
  final String entityType;
  final String externalId;
  final String title;
  final String subTitle;
  final String paymentAmount;
  final String? paymentTag;
  final String? footerText;
  final String? cashbackText;
  final String? expiringText;
  final LogoModel? logo;
  final CtaModel? primaryCta;
  final BackgroundModel? background;
  final FlipperConfig? flipperConfig;

  BillCardModel({
    required this.entityType,
    required this.externalId,
    required this.title,
    required this.subTitle,
    required this.paymentAmount,
    this.paymentTag,
    this.footerText,
    this.cashbackText,
    this.expiringText,
    this.logo,
    this.primaryCta,
    this.background,
    this.flipperConfig,
  });

  factory BillCardModel.fromJson(Map<String, dynamic> json) {
    final props = json['template_properties'] as Map<String, dynamic>? ?? {};
    final body = props['body'] as Map<String, dynamic>? ?? {};
    final ctas = props['ctas'] as Map<String, dynamic>?;
    final bg = props['background'] as Map<String, dynamic>?;

    return BillCardModel(
      entityType: json['entity_type'] ?? '',
      externalId: json['external_id'] ?? '',
      title: body['title'] ?? '',
      subTitle: body['sub_title'] ?? '',
      paymentAmount: body['payment_amount'] ?? '',
      paymentTag: body['payment_tag'],
      footerText: body['footer_text'],
      cashbackText: body['cashback_text'],
      expiringText: body['expiring_text'],
      logo: body['logo'] != null ? LogoModel.fromJson(body['logo']) : null,
      primaryCta: ctas?['primary'] != null
          ? CtaModel.fromJson(ctas!['primary'])
          : null,
      background: bg != null ? BackgroundModel.fromJson(bg) : null,
      flipperConfig: body['flipper_config'] != null
          ? FlipperConfig.fromJson(body['flipper_config'])
          : null,
    );
  }
}

/// Logo data for a card.
class LogoModel {
  final String url;
  final String bgColor;
  final String shape;

  LogoModel({
    required this.url,
    required this.bgColor,
    required this.shape,
  });

  factory LogoModel.fromJson(Map<String, dynamic> json) {
    return LogoModel(
      url: json['url'] ?? '',
      bgColor: json['bg_color'] ?? '#ffffff',
      shape: json['shape'] ?? 'rectangle',
    );
  }
}

/// Call-to-action button data.
class CtaModel {
  final String title;
  final String type;
  final String? backgroundColor;

  CtaModel({
    required this.title,
    required this.type,
    this.backgroundColor,
  });

  factory CtaModel.fromJson(Map<String, dynamic> json) {
    return CtaModel(
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      backgroundColor: json['background_color'],
    );
  }
}

/// Card background configuration.
class BackgroundModel {
  final List<String> colors;
  final String? direction;
  final String? assetUrl;

  BackgroundModel({
    required this.colors,
    this.direction,
    this.assetUrl,
  });

  factory BackgroundModel.fromJson(Map<String, dynamic> json) {
    final color = json['color'] as Map<String, dynamic>?;
    final asset = json['asset'] as Map<String, dynamic>?;

    return BackgroundModel(
      colors: (color?['colors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['#FFFFFF'],
      direction: color?['direction'],
      assetUrl: asset?['url'],
    );
  }
}

/// Flipper animation configuration for the tag text.
class FlipperConfig {
  final List<FlipperItem> items;
  final FlipperItem? finalStage;
  final int flipCount;
  final int flipDelay;

  FlipperConfig({
    required this.items,
    this.finalStage,
    required this.flipCount,
    required this.flipDelay,
  });

  factory FlipperConfig.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return FlipperConfig(
      items: itemsList
          .map((e) => FlipperItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      finalStage: json['final_stage'] != null
          ? FlipperItem.fromJson(json['final_stage'])
          : null,
      flipCount: json['flip_count'] ?? 1,
      flipDelay: json['flip_delay'] ?? 2000,
    );
  }
}

/// Single flipper item containing text.
class FlipperItem {
  final String text;

  FlipperItem({required this.text});

  factory FlipperItem.fromJson(Map<String, dynamic> json) {
    return FlipperItem(text: json['text'] ?? '');
  }
}
