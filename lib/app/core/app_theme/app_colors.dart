import 'package:flutter/material.dart';

/// Centralised color palette for both light and dark themes.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A42D6);
  static const Color accent = Color(0xFF00D4AA);

  // Surfaces – Light
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Surfaces – Dark
  static const Color backgroundDark = Color(0xFF0E0E1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF0F0F8);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Chat bubbles
  static const Color bubbleOutgoing = Color(0xFF6C63FF);
  static const Color bubbleIncoming = Color(0xFFEEEEF8);
  static const Color bubbleIncomingDark = Color(0xFF252540);

  // Status
  static const Color online = Color(0xFF22C55E);
  static const Color offline = Color(0xFF6B7280);
  static const Color transferProgress = Color(0xFF00D4AA);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);

  // Divider
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF2D2D4E);
}
