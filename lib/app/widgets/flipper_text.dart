import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cred_assignment/app/data/models/bill_card_model.dart';
import 'package:cred_assignment/app/utils/app_colors.dart';

/// Flipper text widget that animates through the items
/// in the [FlipperConfig] and then settles on the final stage.
///
/// If no flipper config is provided, it simply shows the [footerText].
class FlipperText extends StatefulWidget {
  final FlipperConfig? flipperConfig;
  final String? footerText;

  const FlipperText({
    super.key,
    this.flipperConfig,
    this.footerText,
  });

  @override
  State<FlipperText> createState() => _FlipperTextState();
}

class _FlipperTextState extends State<FlipperText> {
  int _currentItemIndex = 0;
  bool _reachedFinalStage = false;
  int _flipsDone = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startFlipping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startFlipping() {
    final config = widget.flipperConfig;
    if (config == null || config.items.isEmpty) return;

    final delay = Duration(milliseconds: config.flipDelay);
    final totalFlips = config.flipCount * config.items.length;

    _timer = Timer.periodic(delay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentItemIndex = (_currentItemIndex + 1) % config.items.length;
        _flipsDone++;

        if (_flipsDone >= totalFlips) {
          _reachedFinalStage = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.flipperConfig;

    // If no flipper config, just show footer text
    if (config == null || config.items.isEmpty) {
      if (widget.footerText == null || widget.footerText!.isEmpty) {
        return const SizedBox.shrink();
      }
      return _buildTagText(widget.footerText!);
    }

    // If we've reached final stage, show it
    if (_reachedFinalStage && config.finalStage != null) {
      return _buildTagText(config.finalStage!.text);
    }

    // Show current item with flip animation
    final currentText = config.items[_currentItemIndex].text;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final isEntering = child.key == ValueKey<int>(_currentItemIndex);

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final double value = animation.value;

            // Define the rotation angle.
            // Entering child: rotates from far (90 deg) to flat (0 deg).
            // Exiting child: rotates from flat (0 deg) to far (-90 deg).
            final rotationX = isEntering
                ? (1.0 - value) * -math.pi / 2
                : (1.0 - value) * math.pi / 2;

            // Add vertical offset to simulate a rolling cylinder / flipper.
            final verticalOffset = isEntering
                ? (1.0 - value) * 10
                : (1.0 - value) * -10;

            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002) // Perspective
                  ..translate(0.0, verticalOffset, 0.0)
                  ..rotateX(rotationX)
                  ..scale(0.8 + 0.2 * value), // Slight scale-in
                child: child,
              ),
            );
          },
        );
      },
      child: _buildTagText(
        currentText,
        key: ValueKey<int>(_currentItemIndex),
      ),
    );
  }

  Widget _buildTagText(String text, {Key? key}) {
    // Determine color based on text content
    Color tagColor = AppColors.tagOverdue;
    final lowerText = text.toLowerCase();
    if (lowerText.contains('due today')) {
      tagColor = AppColors.tagDueToday;
    } else if (lowerText.contains('overdue')) {
      tagColor = AppColors.tagOverdue;
    } else if (lowerText.contains('upcoming')) {
      tagColor = AppColors.tagUpcoming;
    } else {
      tagColor = AppColors.tagDueToday;
    }

    return Text(
      text,
      key: key,
      style: TextStyle(
        color: tagColor,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}
