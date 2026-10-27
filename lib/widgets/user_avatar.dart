import 'package:flutter/material.dart';

/// Circular avatar with the user's initials and an optional online dot.
class UserAvatar extends StatelessWidget {
  final String name;
  final bool? online;
  final double radius;

  const UserAvatar({super.key, required this.name, this.online, this.radius = 24});

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.substring(0, p.length < 2 ? p.length : 2).toUpperCase();
    }
    return (parts.first[0] + parts.elementAt(1)[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Stable hue per name so each contact keeps its color.
    final hue = (name.hashCode % 360).abs().toDouble();
    final bg = HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: bg,
          child: Text(
            initials(name),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: radius * 0.7,
            ),
          ),
        ),
        if (online != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.55,
              height: radius * 0.55,
              decoration: BoxDecoration(
                color: online! ? Colors.green : colors.outline,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
