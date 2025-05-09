// dot_widget.dart
import 'package:flutter/material.dart';

class DotWidget extends StatelessWidget {
  final Color color;
  final double size;

  const DotWidget({
    Key? key,
    this.color = Colors.grey,
    this.size = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
