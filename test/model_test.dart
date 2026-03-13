import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/app/data/models/bill_card_model.dart';
import 'package:cred_assignment/app/data/models/bill_section_model.dart';

/// Tests for data model JSON parsing.
///
/// Validates that [BillCardModel], [BillSectionModel], and related
/// sub-models correctly parse the mock API JSON structure.
void main() {
  group('BillCardModel', () {
    test('should parse card JSON with all fields correctly', () {
      final json = {
        'entity_type': 'card',
        'external_id': 'test_id',
        'template_properties': {
          'body': {
            'title': 'SBI',
            'sub_title': 'XXXX XXXX 1236',
            'payment_amount': '₹2,15,705',
            'payment_tag': 'OUTSTANDING',
            'footer_text': 'OVERDUE',
            'logo': {
              'url': 'https://example.com/logo.png',
              'bg_color': '#ffffff',
              'shape': 'rectangle',
            },
          },
          'ctas': {
            'primary': {
              'title': 'Pay ₹2.15L',
              'type': 'deeplink',
              'background_color': '#ffffff',
            },
          },
        },
      };

      final card = BillCardModel.fromJson(json);

      expect(card.entityType, 'card');
      expect(card.externalId, 'test_id');
      expect(card.title, 'SBI');
      expect(card.subTitle, 'XXXX XXXX 1236');
      expect(card.paymentAmount, '₹2,15,705');
      expect(card.paymentTag, 'OUTSTANDING');
      expect(card.footerText, 'OVERDUE');
      expect(card.logo, isNotNull);
      expect(card.logo?.url, 'https://example.com/logo.png');
      expect(card.logo?.bgColor, '#ffffff');
      expect(card.logo?.shape, 'rectangle');
      expect(card.primaryCta, isNotNull);
      expect(card.primaryCta?.title, 'Pay ₹2.15L');
      expect(card.primaryCta?.type, 'deeplink');
      expect(card.flipperConfig, isNull);
    });

    test('should parse card with flipper config correctly', () {
      final json = {
        'entity_type': 'card',
        'external_id': 'test_id_2',
        'template_properties': {
          'body': {
            'title': 'HDFC Bank',
            'sub_title': 'XXXX XXXX 5948',
            'payment_amount': '₹45,000',
            'flipper_config': {
              'final_stage': {'text': 'DUE TODAY'},
              'flip_count': 1,
              'flip_delay': 2000,
              'items': [
                {'text': 'GET 1% BACK AS GOLD UPTO ₹200'},
                {'text': 'DUE TODAY'},
              ],
            },
          },
          'ctas': {
            'primary': {
              'title': 'Pay ₹45,000',
              'type': 'deeplink',
            },
          },
        },
      };

      final card = BillCardModel.fromJson(json);

      expect(card.title, 'HDFC Bank');
      expect(card.subTitle, 'XXXX XXXX 5948');
      expect(card.flipperConfig, isNotNull);
      expect(card.flipperConfig!.items.length, 2);
      expect(card.flipperConfig!.items[0].text, 'GET 1% BACK AS GOLD UPTO ₹200');
      expect(card.flipperConfig!.items[1].text, 'DUE TODAY');
      expect(card.flipperConfig!.finalStage?.text, 'DUE TODAY');
      expect(card.flipperConfig!.flipCount, 1);
      expect(card.flipperConfig!.flipDelay, 2000);
    });

    test('should handle missing optional fields gracefully', () {
      final json = {
        'entity_type': 'card',
        'external_id': 'minimal_id',
        'template_properties': {
          'body': {
            'title': 'Test Card',
            'sub_title': 'Subtitle',
            'payment_amount': '₹100',
          },
        },
      };

      final card = BillCardModel.fromJson(json);

      expect(card.title, 'Test Card');
      expect(card.footerText, isNull);
      expect(card.paymentTag, isNull);
      expect(card.logo, isNull);
      expect(card.primaryCta, isNull);
      expect(card.flipperConfig, isNull);
      expect(card.background, isNull);
      expect(card.isAutoPayEnabled, false);
    });

    test('should set isAutoPayEnabled=true when payment_tag is OUTSTANDING', () {
      final json = {
        'entity_type': 'card',
        'external_id': 'autopay_id',
        'template_properties': {
          'body': {
            'title': 'Auto Card',
            'sub_title': 'Sub',
            'payment_amount': '₹500',
            'payment_tag': 'OUTSTANDING',
          },
        },
      };

      final card = BillCardModel.fromJson(json);
      expect(card.isAutoPayEnabled, true);
    });

    test('should set isAutoPayEnabled=false for non-OUTSTANDING tags', () {
      final json = {
        'entity_type': 'card',
        'external_id': 'no_autopay_id',
        'template_properties': {
          'body': {
            'title': 'Normal Card',
            'sub_title': 'Sub',
            'payment_amount': '₹300',
            'payment_tag': 'PENDING',
          },
        },
      };

      final card = BillCardModel.fromJson(json);
      expect(card.isAutoPayEnabled, false);
    });

    test('should handle completely empty template_properties', () {
      final json = {
        'entity_type': 'card',
        'external_id': 'empty_id',
      };

      final card = BillCardModel.fromJson(json);

      expect(card.title, '');
      expect(card.subTitle, '');
      expect(card.paymentAmount, '');
    });

    test('should parse background model correctly', () {
      final json = {
        'entity_type': 'card',
        'external_id': 'bg_id',
        'template_properties': {
          'body': {
            'title': 'BG Card',
            'sub_title': 'Sub',
            'payment_amount': '₹200',
          },
          'background': {
            'color': {
              'colors': ['#FF0000', '#00FF00'],
              'direction': 'vertical',
            },
            'asset': {
              'url': 'https://example.com/bg.png',
            },
          },
        },
      };

      final card = BillCardModel.fromJson(json);

      expect(card.background, isNotNull);
      expect(card.background!.colors, ['#FF0000', '#00FF00']);
      expect(card.background!.direction, 'vertical');
      expect(card.background!.assetUrl, 'https://example.com/bg.png');
    });
  });

  group('FlipperConfig', () {
    test('should parse flipper config with default values', () {
      final json = {
        'items': [
          {'text': 'Item 1'},
        ],
      };

      final config = FlipperConfig.fromJson(json);

      expect(config.items.length, 1);
      expect(config.items[0].text, 'Item 1');
      expect(config.flipCount, 1);
      expect(config.flipDelay, 5000); // our updated default
      expect(config.finalStage, isNull);
    });

    test('should parse flipper config with all fields', () {
      final json = {
        'items': [
          {'text': 'A'},
          {'text': 'B'},
          {'text': 'C'},
        ],
        'final_stage': {'text': 'Final'},
        'flip_count': 3,
        'flip_delay': 1500,
      };

      final config = FlipperConfig.fromJson(json);

      expect(config.items.length, 3);
      expect(config.finalStage?.text, 'Final');
      expect(config.flipCount, 3);
      expect(config.flipDelay, 1500);
    });

    test('should handle empty items list', () {
      final json = <String, dynamic>{};

      final config = FlipperConfig.fromJson(json);

      expect(config.items, isEmpty);
      expect(config.flipCount, 1);
    });
  });

  group('LogoModel', () {
    test('should parse logo with all fields', () {
      final logo = LogoModel.fromJson({
        'url': 'https://example.com/img.png',
        'bg_color': '#FF5733',
        'shape': 'circle',
      });

      expect(logo.url, 'https://example.com/img.png');
      expect(logo.bgColor, '#FF5733');
      expect(logo.shape, 'circle');
    });

    test('should use default values for missing fields', () {
      final logo = LogoModel.fromJson({});

      expect(logo.url, '');
      expect(logo.bgColor, '#ffffff');
      expect(logo.shape, 'rectangle');
    });
  });

  group('CtaModel', () {
    test('should parse CTA correctly', () {
      final cta = CtaModel.fromJson({
        'title': 'Pay ₹200',
        'type': 'deeplink',
        'background_color': '#000000',
      });

      expect(cta.title, 'Pay ₹200');
      expect(cta.type, 'deeplink');
      expect(cta.backgroundColor, '#000000');
    });

    test('should handle missing background_color', () {
      final cta = CtaModel.fromJson({
        'title': 'Pay',
        'type': 'button',
      });

      expect(cta.backgroundColor, isNull);
    });
  });

  group('BillSectionModel', () {
    test('should parse section JSON correctly', () {
      final json = {
        'template_properties': {
          'body': {
            'title': 'UPCOMING BILLS',
            'bills_count': '2',
            'auto_scroll_enabled': true,
            'cards_animation_config': {
              'count': 10,
              'delay': 3,
              'duration': '0.7',
            },
          },
          'child_list': [
            {
              'entity_type': 'card',
              'external_id': 'id1',
              'template_properties': {
                'body': {
                  'title': 'VIL',
                  'sub_title': 'Miss Blake Murazik',
                  'payment_amount': '₹200',
                  'footer_text': 'due today',
                },
                'ctas': {
                  'primary': {'title': 'Pay ₹200', 'type': 'deeplink'},
                },
              },
            },
          ],
          'ctas': {
            'primary': {'title': 'view all', 'type': 'deeplink'},
          },
        },
      };

      final section = BillSectionModel.fromJson(json);

      expect(section.title, 'UPCOMING BILLS');
      expect(section.billsCount, '2');
      expect(section.autoScrollEnabled, true);
      expect(section.animationConfig, isNotNull);
      expect(section.animationConfig?.count, 10);
      expect(section.animationConfig?.delay, 3);
      expect(section.animationConfig?.duration, 0.7);
      expect(section.cards.length, 1);
      expect(section.cards.first.title, 'VIL');
      expect(section.viewAllCtaTitle, 'view all');
    });

    test('should parse section with multiple cards', () {
      final json = {
        'template_properties': {
          'body': {
            'title': 'BILLS',
            'bills_count': '3',
          },
          'child_list': [
            _makeCardJson('id1', 'Card 1'),
            _makeCardJson('id2', 'Card 2'),
            _makeCardJson('id3', 'Card 3'),
          ],
        },
      };

      final section = BillSectionModel.fromJson(json);

      expect(section.cards.length, 3);
      expect(section.cards[0].title, 'Card 1');
      expect(section.cards[1].title, 'Card 2');
      expect(section.cards[2].title, 'Card 3');
    });

    test('should handle empty child_list', () {
      final json = {
        'template_properties': {
          'body': {
            'title': 'EMPTY SECTION',
            'bills_count': '0',
          },
        },
      };

      final section = BillSectionModel.fromJson(json);

      expect(section.cards, isEmpty);
      expect(section.viewAllCtaTitle, isNull);
      expect(section.animationConfig, isNull);
    });

    test('should default autoScrollEnabled to false', () {
      final json = {
        'template_properties': {
          'body': {
            'title': 'TEST',
          },
        },
      };

      final section = BillSectionModel.fromJson(json);
      expect(section.autoScrollEnabled, false);
    });
  });

  group('CardsAnimationConfig', () {
    test('should parse animation config correctly', () {
      final config = CardsAnimationConfig.fromJson({
        'count': 5,
        'delay': 2,
        'duration': '0.5',
      });

      expect(config.count, 5);
      expect(config.delay, 2);
      expect(config.duration, 0.5);
    });

    test('should use defaults for missing values', () {
      final config = CardsAnimationConfig.fromJson({});

      expect(config.count, 10);
      expect(config.delay, 3);
      expect(config.duration, 0.7);
    });

    test('should handle numeric duration (not string)', () {
      final config = CardsAnimationConfig.fromJson({
        'duration': 1.5,
      });

      expect(config.duration, 1.5);
    });
  });
}

/// Helper to make a minimal card JSON for section tests.
Map<String, dynamic> _makeCardJson(String id, String title) {
  return {
    'entity_type': 'card',
    'external_id': id,
    'template_properties': {
      'body': {
        'title': title,
        'sub_title': 'Sub',
        'payment_amount': '₹100',
      },
    },
  };
}
