import 'package:flutter/material.dart';

import '../../config/palette.dart';

/// 네온 룩 공용 버튼. 메뉴/상점/게임오버에서 공유한다.
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = Palette.core,
    this.filled = true,
    this.width,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool filled;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: filled ? color.withValues(alpha: 0.10) : null,
          border: Border.all(color: color, width: 2),
          boxShadow: filled
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 20)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Palette.textHi : color,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}
