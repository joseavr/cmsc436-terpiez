import 'package:flutter/material.dart';

class SpaceX extends StatelessWidget {
  final double width;
  const SpaceX(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width); // space-y: 16px
  }
}
