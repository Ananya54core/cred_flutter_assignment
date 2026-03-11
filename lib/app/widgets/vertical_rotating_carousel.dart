import 'package:flutter/material.dart';

/// A vertical **stacked-papers** carousel.
///
/// **Resting state** – 3 cards are visible: the front card is fully shown and
/// the next 2 are partially visible behind it, each offset by a small vertical
/// gap (like a stack of papers).
///
/// **Transition** – When the user swipes up, the top card slides upward and
/// out, all remaining cards shift up one position, and a new card appears at
/// the bottom of the stack. No rotation — only vertical translation and slight
/// scale changes.
///
/// Built with [Stack], [Transform], [GestureDetector], [AnimationController].
class VerticalRotatingCarousel extends StatefulWidget {
  /// Card widgets to cycle through.
  final List<Widget> cards;

  /// Height of each card.
  final double cardHeight;

  /// Optional fixed card width.
  final double? cardWidth;

  /// Gap between the two fully-visible cards (px).
  final double cardGap;

  /// Small vertical peek offset for the 3rd card behind the 2nd.
  final double stackPeek;

  /// Scale reduction for the peeking 3rd card.
  final double peekScaleStep;

  /// Duration of the snap / settle animation.
  final Duration animationDuration;

  const VerticalRotatingCarousel({
    super.key,
    required this.cards,
    this.cardHeight = 100,
    this.cardWidth,
    this.cardGap = 2,
    this.stackPeek = 14,
    this.peekScaleStep = 0.04,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<VerticalRotatingCarousel> createState() =>
      _VerticalRotatingCarouselState();
}

class _VerticalRotatingCarouselState extends State<VerticalRotatingCarousel>
    with SingleTickerProviderStateMixin {
  /// Index of the card currently at the **front** of the stack.
  int _currentIndex = 0;

  /// Transition progress: 0 = at rest, 1 = top card fully dismissed.
  double _progress = 0.0;

  late AnimationController _animController;
  late CurvedAnimation _curve;

  double _animStart = 0.0;
  double _animEnd = 0.0;

  int get _total => widget.cards.length;
  int _idx(int i) => ((i % _total) + _total) % _total;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..addListener(_onAnimate);
    _curve =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _animController.dispose();
    _curve.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  //  Animation
  // ---------------------------------------------------------------------------

  void _onAnimate() {
    setState(() {
      _progress = _animStart + (_animEnd - _animStart) * _curve.value;

      if (_curve.value >= 1.0) {
        if (_animEnd >= 1.0) {
          _currentIndex = _idx(_currentIndex + 1);
        }
        _progress = 0.0;
      }
    });
  }

  // ---------------------------------------------------------------------------
  //  Gestures
  // ---------------------------------------------------------------------------

  void _onDragUpdate(DragUpdateDetails details) {
    if (_animController.isAnimating) return;
    setState(() {
      _progress += -details.delta.dy / (widget.cardHeight * 2.0);
      _progress = _progress.clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_animController.isAnimating) return;
    final velocity = -(details.primaryVelocity ?? 0);

    _animStart = _progress;
    _animEnd = (velocity > 250 || _progress > 0.3) ? 1.0 : 0.0;

    _animController
      ..reset()
      ..forward();
  }

  // ---------------------------------------------------------------------------
  //  Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_total == 0) return const SizedBox.shrink();

    // ≤ 2 items → simple static vertical list (no carousel animation).
    if (_total <= 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _total; i++) ...[
              if (i > 0) SizedBox(height: widget.cardGap),
              SizedBox(
                height: widget.cardHeight,
                child: widget.cards[i],
              ),
            ],
          ],
        ),
      );
    }

    // > 2 items → animated carousel.
    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerWidth = constraints.maxWidth;
          final cardW = widget.cardWidth ?? (containerWidth - 32);
          final leftX = (containerWidth - cardW) / 2;
          final t = _progress;

          // Slot Y positions (at rest):
          //   slot 0: y = 0                                    (top card, fully visible)
          //   slot 1: y = cardHeight + cardGap                  (2nd card, fully visible)
          //   slot 2: y = cardHeight + cardGap + stackPeek      (1st peek card behind 2nd)
          //   slot 3: y = cardHeight + cardGap + stackPeek * 2  (2nd peek card behind)
          //   slot 4: y = (incoming, enters during transition)
          //
          // During transition (t: 0→1) each card slides up to the position
          // of the slot above it.

          final slotY = <double>[
            0,                                                           // slot 0
            widget.cardHeight + widget.cardGap,                          // slot 1
            widget.cardHeight + widget.cardGap + widget.stackPeek,       // slot 2
            widget.cardHeight + widget.cardGap + widget.stackPeek * 2,   // slot 3
            widget.cardHeight + widget.cardGap + widget.stackPeek * 3,   // slot 4 (incoming)
          ];
          final slotScale = <double>[
            1.0,                              // slot 0
            1.0,                              // slot 1
            1.0 - widget.peekScaleStep,       // slot 2
            1.0 - widget.peekScaleStep * 2,   // slot 3
            1.0 - widget.peekScaleStep * 3,   // slot 4
          ];

          final cards = <Widget>[];

          for (int slot = 4; slot >= 0; slot--) {
            final cardIndex = _idx(_currentIndex + slot);

            final restY = slotY[slot];
            final restScale = slotScale[slot];

            // Target = position of the slot above (slot - 1).
            final targetSlot = (slot - 1).clamp(0, 4);
            final targetY = slot == 0
                ? -widget.cardHeight * 1.2 // slot 0 exits upward
                : slotY[targetSlot];
            final targetScale = slot == 0
                ? restScale
                : slotScale[targetSlot];

            double y;
            double scale;

            if (slot == 0) {
              // Front card: slides upward and out.
              y = restY - t * widget.cardHeight * 1.2;
              scale = restScale;
            } else if (slot == 4) {
              // Incoming card: appears during second half of transition.
              final appear = ((t - 0.4) / 0.6).clamp(0.0, 1.0);
              y = restY + (targetY - restY) * appear;
              scale = restScale + (targetScale - restScale) * appear;
              if (appear <= 0) continue;
            } else {
              // Cards 1, 2, 3: slide from current slot toward the slot above.
              y = restY + (targetY - restY) * t;
              scale = restScale + (targetScale - restScale) * t;
            }

            cards.add(
              Positioned(
                top: y,
                left: leftX,
                width: cardW,
                height: widget.cardHeight,
                child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()..scale(scale, 1.0),
                  child: widget.cards[cardIndex],
                ),
              ),
            );
          }

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: cards,
          );
        },
      ),
    );
  }
}
