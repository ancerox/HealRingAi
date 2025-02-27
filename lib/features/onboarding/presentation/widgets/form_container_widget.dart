import 'package:flutter/material.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';

class FormContainer extends StatelessWidget {
  final String text;
  final double? width;
  final double height;
  final bool isSelected;
  final VoidCallback onTap;

  const FormContainer({
    super.key,
    required this.text,
    this.width,
    this.height = 55,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: CustomTheme.formBackground,
          border: Border.all(
            color: isSelected
                ? CustomTheme.primaryDefault
                : CustomTheme.formBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
