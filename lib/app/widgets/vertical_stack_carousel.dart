import 'package:flutter/material.dart';
import 'package:stacked_list_carousel/stacked_list_carousel.dart';
import 'package:cred_assignment/app/data/models/bill_card_model.dart';
import 'bill_card.dart';

/// Vertical swipeable carousel using [StackedListCarousel].
/// Replicates the stacked CRED-style card UI.
class VerticalStackCarousel extends StatelessWidget {
  final List<BillCardModel> cards;
  final bool autoScrollEnabled;
  final int autoScrollDelay;
  final double animationDuration;

  const VerticalStackCarousel({
    super.key,
    required this.cards,
    this.autoScrollEnabled = true,
    this.autoScrollDelay = 3,
    this.animationDuration = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    /// For ≤ 2 items → simple list (no carousel needed)
    if (cards.length <= 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BillCard(card: cards[i]),
            ),
          ],
        ],
      );
    }

    /// For > 2 items → stacked carousel
    return SizedBox(
      height: 300, // Important: defines carousel layout space
      child: StackedListCarousel<BillCardModel>(
        items: cards,

        /// looping swipe behavior
        behavior: CarouselBehavior.loop,

        /// builds each card
        cardBuilder: (context, item, size) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: BillCard(card: item),
            ),
          );
        },

        /// height of front card relative to container
        outermostCardHeightFactor: 0.55,

        /// spacing between stacked cards
        itemGapHeightFactor: 0.02,

        /// number of cards visible in stack
        maxDisplayedItemCount: 3,

        /// stack starts from top
        alignment: StackedListAxisAlignment.top,

        /// swipe animation duration
        animationDuration: Duration(
          milliseconds: (animationDuration * 1000).toInt(),
        ),

        /// auto slide only if enabled
        autoSlideDuration: autoScrollEnabled
            ? Duration(seconds: autoScrollDelay)
            : const Duration(days: 365),

        /// swipe callback
        cardSwipedCallback: (item, direction) {
          debugPrint('Swiped: ${item.title} → $direction');
        },
      ),
    );
  }
}