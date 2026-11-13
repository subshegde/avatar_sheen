import 'package:flutter/material.dart';

import 'shade_sweep.dart';

/// A person's initials on a rounded tile with a gradient and a [ShadeSweep]:
/// the profile mark for list cards, headers and app bars.
///
/// Set [imageProvider] to show a photo instead (the initials remain as the
/// fallback while it loads or if it fails).
class ShadeInitialsAvatar extends StatelessWidget {
  const ShadeInitialsAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.shape = ShadeAvatarShape.roundedSquare,
    this.colors = const [Color(0xFF6A5AE0), Color(0xFF4F8CFF)],
    this.textStyle,
    this.imageProvider,
    this.onTap,
  });

  final String name;
  final double size;
  final ShadeAvatarShape shape;

  /// Gradient colours, top-left to bottom-right.
  final List<Color> colors;

  /// Defaults to bold white text at 40% of [size].
  final TextStyle? textStyle;
  final ImageProvider? imageProvider;
  final VoidCallback? onTap;

  /// First and last initial: "Asha Rao" is AR; a single name gives one letter.
  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final radius = shape == ShadeAvatarShape.circle
        ? BorderRadius.circular(size)
        : BorderRadius.circular(size * 0.3);
    final initials = Text(
      initialsOf(name),
      style: textStyle ??
          TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
    );
    return Semantics(
      label: name,
      child: GestureDetector(
        onTap: onTap,
        child: ShadeSweep(
          borderRadius: radius,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: imageProvider == null
                ? initials
                : Image(
                    image: imageProvider!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : initials,
                    errorBuilder: (_, __, ___) => initials,
                  ),
          ),
        ),
      ),
    );
  }
}

enum ShadeAvatarShape { circle, roundedSquare }
