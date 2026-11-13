import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'shade_sequence.dart';

/// Lays a soft band of light over [child] that sweeps from its top-left corner
/// to its bottom-right. The band is translucent, so the child keeps its own
/// colour, background and text; wrap anything (an avatar, a badge, a tile) and
/// give it the same [borderRadius] to keep the light inside its shape.
///
/// Sweeps take turns ([ShadeSequenceCubit]): when several are on screen the first
/// (top) one plays, then the second, and so on; ones scrolled out of sight are
/// skipped. The animation drives only the paint, never a rebuild of [child].
/// When the platform asks for reduced motion the child is shown still.
class ShadeSweep extends StatefulWidget {
  const ShadeSweep({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.intensity = 0.5,
    this.color = Colors.white,
  });

  final Widget child;

  /// The shape the light is kept inside; match the child's own corners.
  final BorderRadius borderRadius;

  /// How bright the band is, 0 (invisible) to 1 (solid at its core).
  final double intensity;

  /// The colour of the light. White suits dark or saturated backgrounds.
  final Color color;

  @override
  State<ShadeSweep> createState() => _ShadeSweepState();
}

class _ShadeSweepState extends State<ShadeSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  final Object _token = Object();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ShadeSequenceCubit.turn,
    );
    _curved = CurvedAnimation(parent: _controller, curve: Curves.linear);
    // Joins once it is on screen, in the frame after the first layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ShadeSequenceCubit.instance.register(_token, context);
    });
  }

  @override
  void dispose() {
    ShadeSequenceCubit.instance.unregister(_token);
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return BlocListener<ShadeSequenceCubit, Object?>(
      bloc: ShadeSequenceCubit.instance,
      listenWhen: (_, current) => identical(current, _token),
      listener: (_, __) => _controller.forward(from: 0),
      child: RepaintBoundary(
        child: CustomPaint(
          foregroundPainter: _SweepPainter(
            animation: _curved,
            borderRadius: widget.borderRadius,
            intensity: widget.intensity,
            color: widget.color,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _SweepPainter extends CustomPainter {
  _SweepPainter({
    required this.animation,
    required this.borderRadius,
    required this.intensity,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final BorderRadius borderRadius;
  final double intensity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // At rest (before a turn and after it) nothing is drawn.
    if (size.isEmpty || animation.value <= 0 || animation.value >= 1) return;
    final bounds = Offset.zero & size;
    canvas.save();
    canvas.clipRRect(borderRadius.toRRect(bounds));

    // A gradient box the size of the child slides along the diagonal; only the
    // middle is light, so one soft band crosses the child, starting just
    // outside the top-left corner and ending just outside the bottom-right.
    final travel = (animation.value * 2 - 1) * 0.75;
    final slid =
        bounds.shift(Offset(size.width * travel, size.height * travel));
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: intensity * 0.55),
            color.withValues(alpha: intensity),
            color.withValues(alpha: intensity * 0.55),
            color.withValues(alpha: 0),
          ],
          stops: const [0.30, 0.43, 0.5, 0.57, 0.70],
        ).createShader(slid),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SweepPainter old) =>
      old.borderRadius != borderRadius ||
      old.intensity != intensity ||
      old.color != color;
}
