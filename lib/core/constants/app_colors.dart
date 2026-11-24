import 'package:flutter/material.dart';

/// App color palette reflecting a premium, modern financial institution.
/// Deep Navy Blue primary, Subtle Green accents, clean neutrals.
class AppColors {
  AppColors._();

  // Primary - Deep Navy Blue
  static const Color primaryNavy = Color(0xFF0F172A); // Slate 900
  static const Color primaryNavyLight = Color(0xFF1E293B); // Slate 800
  static const Color primaryBlue = Color(0xFF1D4ED8); // Blue 700
  static const Color primaryBlueAccent = Color(0xFF3B82F6); // Blue 500

  // Secondary & Accents - Subtle Financial Green
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color accentGreenDark = Color(0xFF047857); // Emerald 700
  static const Color accentGreenLight = Color(0xFFD1FAE5); // Emerald 100

  // Secondary Accents - Coral / Red for Sell Rate
  static const Color sellRateRed = Color(0xFFE11D48); // Rose 600
  static const Color sellRateRedLight = Color(0xFFFFE4E6); // Rose 100

  // Buy Rate Color (Financial Green)
  static const Color buyRateGreen = Color(0xFF059669); // Emerald 600
  static const Color buyRateGreenLight = Color(0xFFECFDF5); // Emerald 50

  // Warnings / Demo
  static const Color warningAmber = Color(0xFFD97706); // Amber 600
  static const Color warningAmberLight = Color(0xFFFEF3C7); // Amber 100

  // Status colors
  static const Color statusOnline = Color(0xFF10B981);
  static const Color statusOffline = Color(0xFFEF4444);

  // Neutrals - Light Mode
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200

  // Neutrals - Dark Mode
  static const Color darkBackground = Color(0xFF0B132B);
  static const Color darkSurface = Color(0xFF1C2541);
  static const Color darkSurfaceVariant = Color(0xFF283457);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);
}
