import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/app/data/models/bill_card_model.dart';
import 'package:cred_assignment/app/data/models/bill_section_model.dart';

void main() {
  group('BillCardModel', () {
    test('should parse card JSON correctly', () {
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

      expect(card.title, 'SBI');
      expect(card.subTitle, 'XXXX XXXX 1236');
      expect(card.paymentAmount, '₹2,15,705');
      expect(card.paymentTag, 'OUTSTANDING');
      expect(card.footerText, 'OVERDUE');
      expect(card.logo?.url, 'https://example.com/logo.png');
      expect(card.primaryCta?.title, 'Pay ₹2.15L');
      expect(card.flipperConfig, isNull);
    });

    test('should parse flipper config correctly', () {
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
      expect(card.flipperConfig, isNotNull);
      expect(card.flipperConfig!.items.length, 2);
      expect(card.flipperConfig!.finalStage?.text, 'DUE TODAY');
      expect(card.flipperConfig!.flipCount, 1);
      expect(card.flipperConfig!.flipDelay, 2000);
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
      expect(section.animationConfig?.count, 10);
      expect(section.animationConfig?.duration, 0.7);
      expect(section.cards.length, 1);
      expect(section.cards.first.title, 'VIL');
      expect(section.viewAllCtaTitle, 'view all');
    });
  });
}
