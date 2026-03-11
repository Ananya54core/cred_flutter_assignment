import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cred_assignment/app/data/models/bill_card_model.dart';
import 'package:cred_assignment/app/utils/app_colors.dart';

/// Flipper text widget with a smooth 3D cube-rotation animation.
///
/// Each transition spins like a cube face: the old text rotates upward
/// while the new text rotates in from below. Uses an explicit
/// [AnimationController] for butter-smooth 60fps transitions.
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

class _FlipperTextState extends State<FlipperText>
    with SingleTickerProviderStateMixin {
  int _currentItemIndex = 0;
  int _previousItemIndex = 0;
  bool _reachedFinalStage = false;
  int _flipsDone = 0;
  Timer? _timer;

  late final AnimationController _animController;
  late final Animation<double> _animation;

  /// Whether a cube-spin is currently in progress.
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isAnimating = false);
      }
    });

    _startFlipping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startFlipping() {
    final config = widget.flipperConfig;
    if (config == null || config.items.isEmpty) return;

    final delay = const Duration(milliseconds: 5000);
    final totalFlips = config.flipCount * config.items.length;

    _timer = Timer.periodic(delay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _flipsDone++;
      final nextIndex = (_currentItemIndex + 1) % config.items.length;

      if (_flipsDone >= totalFlips) {
        timer.cancel();
        // Animate to final stage
        setState(() {
          _previousItemIndex = _currentItemIndex;
          _reachedFinalStage = true;
          _isAnimating = true;
        });
        _animController.forward(from: 0.0);
      } else {
        setState(() {
          _previousItemIndex = _currentItemIndex;
          _currentItemIndex = nextIndex;
          _isAnimating = true;
        });
        _animController.forward(from: 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.flipperConfig;

    // ── No flipper config → static footer text ──
    if (config == null || config.items.isEmpty) {
      if (widget.footerText == null || widget.footerText!.isEmpty) {
        return const SizedBox.shrink();
      }
      return _buildTagText(widget.footerText!);
    }

    // ── Determine outgoing & incoming text ──
    final String outgoingText = config.items[_previousItemIndex].text;
    final String incomingText = _reachedFinalStage && config.finalStage != null
        ? config.finalStage!.text
        : config.items[_currentItemIndex].text;

    // ── Static (no animation running) ──
    if (!_isAnimating) {
      final staticText = _reachedFinalStage && config.finalStage != null
          ? config.finalStage!.text
          : config.items[_currentItemIndex].text;
      return _buildTagText(staticText);
    }

    // ── 3D cube-rotation transition ──
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final double t = _animation.value;

        return ClipRect(
          child: SizedBox(
            height: 28,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outgoing text – rotates upward and fades out
                _buildCubeFace(
                  text: outgoingText,
                  rotationX: t * (math.pi / 2),       // 0 → 90°
                  translateY: -t * 10.0,               // slides up
                  opacity: (1.0 - t * 1.5).clamp(0.0, 1.0),
                ),
                // Incoming text – rotates in from below
                _buildCubeFace(
                  text: incomingText,
                  rotationX: (1.0 - t) * -(math.pi / 2), // -90° → 0
                  translateY: (1.0 - t) * 10.0,           // slides up into place
                  opacity: (t * 1.5).clamp(0.0, 1.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a single cube face with 3D perspective rotation.
  Widget _buildCubeFace({
    required String text,
    required double rotationX,
    required double translateY,
    required double opacity,
  }) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.004) // perspective
        ..translate(0.0, translateY, 0.0)
        ..rotateX(rotationX),
      child: Opacity(
        opacity: opacity,
        child: _buildTagText(text),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────

  /// Converts text to sentence case: first letter uppercase, rest lowercase.
  String _toSentenceCase(String input) {
    if (input.isEmpty) return input;
    final trimmed = input.trim();
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
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
      _toSentenceCase(text),
      key: key,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: tagColor,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}
