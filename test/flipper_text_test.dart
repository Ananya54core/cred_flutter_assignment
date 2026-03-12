import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/app/data/models/bill_card_model.dart';
import 'package:cred_assignment/app/widgets/flipper_text.dart';

/// Widget tests for [FlipperText].
///
/// Validates:
/// - Shows footer text when no flipper config
/// - Shows flipper items when config is present
/// - Cycles through items over time
/// - Shows nothing when both are null
void main() {
  /// Wraps the widget in a MaterialApp for testing.
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('FlipperText — tag text behavior', () {
    testWidgets('shows footer text when flipperConfig is null',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        const FlipperText(
          flipperConfig: null,
          footerText: 'OVERDUE',
        ),
      ));

      // Footer text should be shown (sentence-cased)
      expect(find.text('Overdue'), findsOneWidget);
    });

    testWidgets('shows nothing when both flipperConfig and footerText are null',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        const FlipperText(
          flipperConfig: null,
          footerText: null,
        ),
      ));

      // Should render SizedBox.shrink() — no text at all
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('shows nothing for empty footerText and null flipperConfig',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        const FlipperText(
          flipperConfig: null,
          footerText: '',
        ),
      ));

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('shows first flipper item initially when config is present',
        (tester) async {
      final config = FlipperConfig(
        items: [
          FlipperItem(text: 'GET CASHBACK'),
          FlipperItem(text: 'DUE TODAY'),
        ],
        flipCount: 1,
        flipDelay: 5000,
      );

      await tester.pumpWidget(buildTestApp(
        FlipperText(flipperConfig: config),
      ));

      // First item should be visible initially
      expect(find.text('Get cashback'), findsOneWidget);
    });

    testWidgets('cycles to next item after flipDelay', (tester) async {
      final config = FlipperConfig(
        items: [
          FlipperItem(text: 'ITEM ONE'),
          FlipperItem(text: 'ITEM TWO'),
        ],
        flipCount: 1,
        flipDelay: 1000, // 1 second for faster test
      );

      await tester.pumpWidget(buildTestApp(
        FlipperText(flipperConfig: config),
      ));

      // Initially shows first item
      expect(find.text('Item one'), findsOneWidget);

      // Advance time past the flip delay + animation duration
      await tester.pump(const Duration(milliseconds: 1100));
      // Let animation complete
      await tester.pumpAndSettle();

      // Should now show second item
      expect(find.text('Item two'), findsOneWidget);
    });

    testWidgets('cycles back to first item (continuous loop)', (tester) async {
      final config = FlipperConfig(
        items: [
          FlipperItem(text: 'ALPHA'),
          FlipperItem(text: 'BETA'),
        ],
        flipCount: 1,
        flipDelay: 500, // fast for testing
      );

      await tester.pumpWidget(buildTestApp(
        FlipperText(flipperConfig: config),
      ));

      // Initially: ALPHA
      expect(find.text('Alpha'), findsOneWidget);

      // After 1st flip: BETA
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Beta'), findsOneWidget);

      // After 2nd flip: back to ALPHA (continuous cycle)
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('includes finalStage in the sequence', (tester) async {
      final config = FlipperConfig(
        items: [
          FlipperItem(text: 'STEP ONE'),
        ],
        finalStage: FlipperItem(text: 'FINAL'),
        flipCount: 1,
        flipDelay: 500,
      );

      await tester.pumpWidget(buildTestApp(
        FlipperText(flipperConfig: config),
      ));

      // Initially: STEP ONE
      expect(find.text('Step one'), findsOneWidget);

      // After flip: FINAL
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Final'), findsOneWidget);
    });

    testWidgets('converts "DUE" to "Due soon"', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const FlipperText(
          flipperConfig: null,
          footerText: 'DUE',
        ),
      ));

      // "DUE" should be converted to "Due soon"
      expect(find.text('Due soon'), findsOneWidget);
    });

    testWidgets('does not flip when only one item exists', (tester) async {
      final config = FlipperConfig(
        items: [
          FlipperItem(text: 'ONLY ONE'),
        ],
        flipCount: 1,
        flipDelay: 500,
      );

      await tester.pumpWidget(buildTestApp(
        FlipperText(flipperConfig: config),
      ));

      expect(find.text('Only one'), findsOneWidget);

      // After waiting, it should still show the same text (no flip)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
      expect(find.text('Only one'), findsOneWidget);
    });
  });
}
