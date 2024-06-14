import 'package:flutter/material.dart';

class SpaceY extends StatelessWidget {
  final double height;
  const SpaceY(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height); // space-y: 16px
  }
}
