import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/app/widgets/vertical_rotating_carousel.dart';

/// Widget tests for [VerticalRotatingCarousel].
///
/// Validates:
/// - ≤2 items: renders as a simple static Column (no swipe gesture)
/// - >2 items: renders as a swipeable carousel with GestureDetector
/// - 0 items: renders nothing
/// - Swipe-up gesture advances to the next card
///
/// Note: The carousel uses 5 visible slots (0–4), so testing requires
/// at least 5 unique cards to avoid duplicate-key issues in the Stack.
/// This matches the real usage (mock1 = 2 cards, mock2 = 9 cards).
void main() {
  /// Helper to build a test card.
  Widget makeCard(int index, String label) {
    return Container(
      key: ValueKey('card_$index'),
      color: Colors.white,
      child: Center(child: Text(label)),
    );
  }

  /// Wraps the carousel in a MaterialApp with bounded constraints.
  Widget buildTestApp(List<Widget> cards) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 600,
          width: 400,
          child: VerticalRotatingCarousel(
            cards: cards,
            cardHeight: 100,
          ),
        ),
      ),
    );
  }

  group('VerticalRotatingCarousel — ≤2 items (static list)', () {
    testWidgets('renders nothing for 0 items', (tester) async {
      await tester.pumpWidget(buildTestApp([]));

      // Should not have a swipe-enabled GestureDetector
      expect(
        find.byWidgetPredicate(
          (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
        ),
        findsNothing,
      );
    });

    testWidgets('renders static list for 1 item', (tester) async {
      await tester.pumpWidget(buildTestApp([
        makeCard(0, 'Card 1'),
      ]));

      expect(find.text('Card 1'), findsOneWidget);
      // No carousel GestureDetector
      expect(
        find.byWidgetPredicate(
          (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
        ),
        findsNothing,
      );
    });

    testWidgets('renders static list for 2 items (mock1 state)',
        (tester) async {
      await tester.pumpWidget(buildTestApp([
        makeCard(0, 'SBI - XXXX 1236'),
        makeCard(1, 'SBI - XXXX 1111'),
      ]));

      // Both cards visible as simple list
      expect(find.text('SBI - XXXX 1236'), findsOneWidget);
      expect(find.text('SBI - XXXX 1111'), findsOneWidget);
      // No swipe gesture
      expect(
        find.byWidgetPredicate(
          (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
        ),
        findsNothing,
      );
    });
  });

  group('VerticalRotatingCarousel — >2 items (carousel)', () {
    testWidgets('renders swipeable carousel for 9 items (mock2 state)',
        (tester) async {
      final cards =
          List.generate(9, (i) => makeCard(i, 'Card ${i + 1}'));
      await tester.pumpWidget(buildTestApp(cards));

      // GestureDetector for swiping should exist
      expect(
        find.byWidgetPredicate(
          (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
        ),
        findsOneWidget,
      );

      // Front card "Card 1" should be visible
      expect(find.text('Card 1'), findsOneWidget);
    });

    testWidgets('swipe up advances to next card', (tester) async {
      final cards =
          List.generate(9, (i) => makeCard(i, 'Card ${i + 1}'));
      await tester.pumpWidget(buildTestApp(cards));

      expect(find.text('Card 1'), findsOneWidget);

      final gesture = find.byWidgetPredicate(
        (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
      );

      // Swipe up
      await tester.drag(gesture, const Offset(0, -250));
      // Pump frames manually for animation
      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // After swipe, "Card 2" should be the front card
      expect(find.text('Card 2'), findsOneWidget);
    });

    testWidgets('multiple consecutive swipes work correctly', (tester) async {
      final cards =
          List.generate(9, (i) => makeCard(i, 'Card ${i + 1}'));
      await tester.pumpWidget(buildTestApp(cards));

      final gesture = find.byWidgetPredicate(
        (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
      );

      // Swipe 1: Card 1 → Card 2
      await tester.drag(gesture, const Offset(0, -250));
      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.text('Card 2'), findsOneWidget);

      // Swipe 2: Card 2 → Card 3
      await tester.drag(gesture, const Offset(0, -250));
      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.text('Card 3'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('carousel wraps around after swiping through all cards',
        (tester) async {
      final cards =
          List.generate(9, (i) => makeCard(i, 'Card ${i + 1}'));
      await tester.pumpWidget(buildTestApp(cards));

      final gesture = find.byWidgetPredicate(
        (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
      );

      // Swipe through all 9 cards
      for (int swipe = 0; swipe < 9; swipe++) {
        await tester.drag(gesture, const Offset(0, -250));
        for (int i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      }

      // After 9 swipes, should wrap back to Card 1
      expect(find.text('Card 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
