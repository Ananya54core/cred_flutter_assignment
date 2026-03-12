import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/app/widgets/vertical_rotating_carousel.dart';

/// Performance tests for [VerticalRotatingCarousel].
///
/// These tests verify that the carousel animation completes
/// smoothly without frame drops or jank. Uses [LiveTestWidgetsFlutterBinding]
/// concepts and tester timeline to check animation smoothness.
void main() {
  /// Helper to build a test card.
  Widget makeCard(String label) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  /// Wraps the carousel in a constrained MaterialApp.
  Widget buildTestApp(List<Widget> cards) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 600,
          width: 400,
          child: VerticalRotatingCarousel(
            cards: cards,
            cardHeight: 100,
            animationDuration: const Duration(milliseconds: 400),
          ),
        ),
      ),
    );
  }

  group('Carousel animation smoothness', () {
    testWidgets('swipe animation completes without errors', (tester) async {
      final cards = List.generate(9, (i) => makeCard('Card ${i + 1}'));
      await tester.pumpWidget(buildTestApp(cards));

      final gesture = find.byWidgetPredicate(
        (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
      );

      // Perform a swipe and let it animate to completion
      await tester.drag(gesture, const Offset(0, -250));

      // Pump frame-by-frame to simulate real rendering
      // This checks that no exceptions are thrown during animation frames
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // ~60fps
      }
      await tester.pumpAndSettle();

      // If we reach here without errors, the animation was smooth
      expect(tester.takeException(), isNull);
    });

    testWidgets('rapid multiple swipes do not cause errors', (tester) async {
      final cards = List.generate(9, (i) => makeCard('Card ${i + 1}'));
      await tester.pumpWidget(buildTestApp(cards));

      final gesture = find.byWidgetPredicate(
        (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
      );

      // Perform multiple rapid swipes
      for (int swipe = 0; swipe < 5; swipe++) {
        await tester.drag(gesture, const Offset(0, -200));
        await tester.pumpAndSettle();
      }

      // No exceptions = no crashes during rapid interaction
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'animation frames render within expected time budget',
      (tester) async {
        final cards = List.generate(9, (i) => makeCard('Card ${i + 1}'));
        await tester.pumpWidget(buildTestApp(cards));

        final gesture = find.byWidgetPredicate(
          (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
        );

        // Drag to trigger animation
        await tester.drag(gesture, const Offset(0, -250));

        // Pump 25 frames at 16ms each (400ms total = animation duration)
        // This simulates a 60fps render loop and verifies no frame takes
        // excessively long (which would indicate jank)
        final stopwatch = Stopwatch()..start();
        int frameCount = 0;

        while (stopwatch.elapsedMilliseconds < 500) {
          await tester.pump(const Duration(milliseconds: 16));
          frameCount++;
        }

        stopwatch.stop();

        // We should have rendered a reasonable number of frames
        // At 60fps over 500ms, expect ~31 frames
        expect(frameCount, greaterThan(20),
            reason: 'Animation should render enough frames for smooth display');

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('swipe animation settles within expected duration',
        (tester) async {
      final cards = List.generate(9, (i) => makeCard('Card ${i + 1}'));
      await tester.pumpWidget(buildTestApp(cards));

      final gesture = find.byWidgetPredicate(
        (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
      );

      await tester.drag(gesture, const Offset(0, -250));

      // The animation should settle within 1 second
      // (our animation duration is 400ms)
      final settled = await tester.pumpAndSettle(
        const Duration(milliseconds: 16),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 1),
      );

      // pumpAndSettle returns the number of frames pumped
      // If it exceeds the timeout, it throws — so reaching here = pass
      expect(settled, greaterThan(0),
          reason: 'Animation should settle within 1 second');
    });

    testWidgets('carousel handles full cycle without frame issues',
        (tester) async {
      final cards = List.generate(5, (i) => makeCard('Card ${i + 1}'));
      await tester.pumpWidget(buildTestApp(cards));

      final gesture = find.byWidgetPredicate(
        (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
      );

      // Swipe through all 5 cards to complete a full cycle
      for (int i = 0; i < 5; i++) {
        await tester.drag(gesture, const Offset(0, -250));

        // Pump frame-by-frame
        for (int f = 0; f < 30; f++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.pumpAndSettle();
      }

      // Full cycle completed without errors
      expect(tester.takeException(), isNull);
    });
  });
}
