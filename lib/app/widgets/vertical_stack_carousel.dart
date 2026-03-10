import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cred_assignment/app/data/models/bill_card_model.dart';
import 'bill_card.dart';

/// A vertical swipeable card-stack carousel.
///
/// Shows cards in a stacked layout. The user swipes up/down to navigate.
/// For ≤ 2 items: shows a simple column list.
/// For > 2 items: shows the animated stack with swipe gestures.
class VerticalStackCarousel extends StatefulWidget {
  final List<BillCardModel> cards;
  final double cardHeight;

  const VerticalStackCarousel({
    super.key,
    required this.cards,
    this.cardHeight = 100,
  });

  @override
  State<VerticalStackCarousel> createState() => _VerticalStackCarouselState();
}

class _VerticalStackCarouselState extends State<VerticalStackCarousel>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  double _dragOffset = 0;
  late AnimationController _animController;
  late Animation<double> _animation;

  /// How many cards are visible behind the front card.
  static const int _maxVisibleCards = 3;

  /// Vertical offset between stacked cards.
  static const double _stackSpacing = 12;

  /// Scale reduction per card in the stack.
  static const double _scaleStep = 0.04;

  /// Minimum drag distance to trigger a card change.
  static const double _swipeThreshold = 60;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset < -_swipeThreshold &&
        _currentIndex < widget.cards.length - 1) {
      _animateToNext();
    } else if (_dragOffset > _swipeThreshold && _currentIndex > 0) {
      _animateToPrevious();
    } else {
      _animateSnapBack();
    }
  }

  void _animateToNext() {
    _animation = Tween<double>(begin: _dragOffset, end: -200).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0).then((_) {
      setState(() {
        _currentIndex++;
        _dragOffset = 0;
      });
    });
  }

  void _animateToPrevious() {
    _animation = Tween<double>(begin: _dragOffset, end: 200).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0).then((_) {
      setState(() {
        _currentIndex--;
        _dragOffset = 0;
      });
    });
  }

  void _animateSnapBack() {
    _animation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;

    // For ≤ 2 items, show a simple column layout
    if (cards.length <= 2) {
      return _buildSimpleList(cards);
    }

    return _buildStackCarousel(cards);
  }

  Widget _buildSimpleList(List<BillCardModel> cards) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: cards.map((card) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BillCard(card: card),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStackCarousel(List<BillCardModel> cards) {
    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final animatedDrag =
              _animController.isAnimating ? _animation.value : _dragOffset;

          return SizedBox(
            height: widget.cardHeight + (_maxVisibleCards * _stackSpacing) + 40,
            child: Stack(
              clipBehavior: Clip.none,
              children: _buildCardStack(cards, animatedDrag),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCardStack(List<BillCardModel> cards, double drag) {
    final List<Widget> stackChildren = [];
    final int totalCards = cards.length;

    for (int i = _maxVisibleCards; i >= 0; i--) {
      final cardIndex = _currentIndex + i;
      if (cardIndex >= totalCards) continue;

      final isTopCard = i == 0;

      double yOffset = i * _stackSpacing;
      double scale = 1.0 - (i * _scaleStep);
      double opacity = 1.0 - (i * 0.15);

      if (isTopCard) {
        yOffset += drag;
        final dragProgress = (drag.abs() / 200).clamp(0.0, 1.0);
        opacity = 1.0 - (dragProgress * 0.3);
      } else {
        final dragProgress = (drag.abs() / 200).clamp(0.0, 1.0);
        yOffset -= dragProgress * _stackSpacing;
        scale += dragProgress * _scaleStep;
        opacity = math.min(1.0, opacity + dragProgress * 0.15);
      }

      opacity = opacity.clamp(0.0, 1.0);
      scale = scale.clamp(0.7, 1.0);

      stackChildren.add(
        Positioned(
          top: yOffset,
          left: 16,
          right: 16,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: opacity,
              child: RepaintBoundary(
                child: BillCard(card: cards[cardIndex]),
              ),
            ),
          ),
        ),
      );
    }

    return stackChildren;
  }
}

/// Wrapper around [AnimatedWidget] that accepts a builder callback.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
