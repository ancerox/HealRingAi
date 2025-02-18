import 'package:flutter/material.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';

class GradientBorderBox extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsets? margin;
  final Color? innerColor;
  final List<Color>? BordergradientColors;
  final List<Color>? gradientColors;
  final double? gradientOpacity;
  final double paddingValue;
  final double borderRadius;

  const GradientBorderBox({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.margin,
    this.innerColor,
    this.BordergradientColors,
    this.gradientColors,
    this.gradientOpacity,
    required this.paddingValue,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 5),
      height: height ?? 55,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: BordergradientColors ??
              [
                CustomTheme.primaryDefault,
                const Color(0xFFBEEEE6),
              ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(paddingValue), // border thickness
        child: Container(
          decoration: BoxDecoration(
            color: innerColor ?? Colors.black,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (gradientColors?[0] ?? CustomTheme.primaryDefault)
                      .withOpacity(gradientOpacity ?? 0.2),
                  (gradientColors?[1] ?? const Color(0xFFBEEEE6))
                      .withOpacity(gradientOpacity ?? 0.2),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
