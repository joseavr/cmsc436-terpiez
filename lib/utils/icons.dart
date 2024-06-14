import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The `AppIcon` widget that displays SVG asset from the `assets/icons` directory. <br/>
/// `String iconName` - The path to the SVG asset. <br/>
/// `double size` - The size of the icon. <br/>
/// `Color color` - The color of the icon. <br/>
class AppIcon extends StatelessWidget {
  const AppIcon({
    Key? key,
    required this.iconName,
    this.size = 24.0,
    this.color,
  }) : super(key: key);

  final String iconName;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconName,
      width: size,
      height: size,
      color: color,
    );
  }
}
