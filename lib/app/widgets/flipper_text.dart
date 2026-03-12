import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cred_assignment/app/data/models/bill_card_model.dart';
import 'package:cred_assignment/app/utils/app_colors.dart';

/// Displays the tag text for a bill card with a 3D cube-rotation animation.
///
/// Uses [FlipperConfig] to cycle through text items with a vertical
/// cube-spin transition that rotates the old text upward and the new
/// text in from below — like faces on a rotating cube.
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
  final List<String> _sequence = [];
  int _currentIndex = 0;
  int _nextIndex = 0;
  Timer? _timer;

  late AnimationController _animController;
  late Animation<double> _animation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = _nextIndex;
          _isAnimating = false;
        });
        _animController.reset();
      }
    });

    _buildSequence();
    _startTimer();
  }

  @override
  void didUpdateWidget(FlipperText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flipperConfig != oldWidget.flipperConfig ||
        widget.footerText != oldWidget.footerText) {
      _stopTimer();
      _animController.reset();
      _isAnimating = false;
      _buildSequence();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _animController.dispose();
    super.dispose();
  }

  void _buildSequence() {
    _sequence.clear();
    _currentIndex = 0;
    _nextIndex = 0;

    final config = widget.flipperConfig;
    if (config == null || config.items.isEmpty) {
      if (widget.footerText != null && widget.footerText!.isNotEmpty) {
        _sequence.add(widget.footerText!);
      }
      return;
    }

    // Add items multiple times based on flipCount
    for (int i = 0; i < config.flipCount; i++) {
      for (var item in config.items) {
        _sequence.add(item.text);
      }
    }

    // Add final stage if it exists
    if (config.finalStage != null && config.finalStage!.text.isNotEmpty) {
      if (_sequence.isEmpty || _sequence.last != config.finalStage!.text) {
        _sequence.add(config.finalStage!.text);
      }
    }
  }

  void _startTimer() {
    if (_sequence.length <= 1) return;

    final delayMs = widget.flipperConfig?.flipDelay ?? 5000;

    _timer = Timer.periodic(Duration(milliseconds: delayMs), (timer) {
      if (!mounted || _isAnimating) return;

      setState(() {
        _nextIndex = (_currentIndex + 1) % _sequence.length;
        _isAnimating = true;
      });
      _animController.forward();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_sequence.isEmpty) return const SizedBox.shrink();

    // Always use the same layout structure to prevent position shifts
    return SizedBox(
      height: 28,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final value = _isAnimating ? _animation.value : 0.0;

            return Stack(
              alignment: Alignment.center,
              children: [
                // ── Current text (static when idle, rotates out when animating) ──
                if (!_isAnimating || value <= 0.5)
                  _buildCubeFace(
                    text: _sequence[_currentIndex],
                    rotationAngle: _isAnimating ? -value * (math.pi / 2) : 0.0,
                    opacity: _isAnimating ? 1.0 - (value * 2).clamp(0.0, 1.0) : 1.0,
                    translateY: _isAnimating ? -value * 8 : 0.0,
                  ),

                // ── Incoming text: rotates from 90° → 0° (comes up from below) ──
                if (_isAnimating && value > 0.0)
                  _buildCubeFace(
                    text: _sequence[_nextIndex],
                    rotationAngle: (1.0 - value) * (math.pi / 2),
                    opacity: (value * 2).clamp(0.0, 1.0),
                    translateY: (1.0 - value) * 8,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds a single face of the "cube" with 3D perspective rotation.
  Widget _buildCubeFace({
    required String text,
    required double rotationAngle,
    required double opacity,
    required double translateY,
  }) {
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.004) // perspective
      ..rotateX(rotationAngle);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0.0, translateY),
        child: Transform(
          alignment: Alignment.center,
          transform: transform,
          child: _buildTagText(text),
        ),
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

    // Quick fix: The mockup API sends literally just "DUE" for the BESCOM card,
    // which looks incomplete. We gracefully handle it to "Due soon" so it reads better.
    if (trimmed.toUpperCase() == 'DUE') {
      return 'Due soon';
    }

    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  Widget _buildTagText(String text, {Key? key}) {
    // Determine color based on text content
    Color tagColor = AppColors.tagOverdue;
    final lowerText = text.toLowerCase();

    if (lowerText.contains('due today') || lowerText.contains('due soon')) {
      tagColor = AppColors.tagDueToday;
    } else if (lowerText.contains('overdue')) {
      tagColor = AppColors.tagOverdue;
    } else if (lowerText.contains('upcoming') ||
        lowerText.contains('get') ||
        lowerText.contains('cashback')) {
      tagColor = AppColors.tagUpcoming;
    } else {
      tagColor = AppColors.tagDueToday; // fallback
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
