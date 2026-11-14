// lib/core/widgets/glass_input.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;

  const GlassInput({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.maxLines = 1,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: const TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: StoryJobTheme.textMuted,
              fontSize: 13,
            ),
            labelStyle: const TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 13.5,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: StoryJobTheme.primaryViolet, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.90),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: StoryJobTheme.cardBorder, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: StoryJobTheme.cardBorder, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.60),
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFFEF4444).withValues(alpha: 0.60),
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}