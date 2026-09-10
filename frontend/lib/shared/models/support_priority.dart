import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Support Priority enum (Never called clinical or psychiatric diagnosis).
/// LOW (Green) | MODERATE (Amber) | HIGH (Warm Orange) | URGENT (Muted Red).
enum SupportPriority {
  low,
  moderate,
  high,
  urgent;

  static SupportPriority fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'MODERATE':
        return SupportPriority.moderate;
      case 'HIGH':
        return SupportPriority.high;
      case 'URGENT':
        return SupportPriority.urgent;
      case 'LOW':
      default:
        return SupportPriority.low;
    }
  }

  String get label {
    switch (this) {
      case SupportPriority.low:
        return 'LOW';
      case SupportPriority.moderate:
        return 'MODERATE';
      case SupportPriority.high:
        return 'HIGH';
      case SupportPriority.urgent:
        return 'URGENT';
    }
  }

  Color get color {
    switch (this) {
      case SupportPriority.low:
        return AppColors.priorityLow;
      case SupportPriority.moderate:
        return AppColors.priorityModerate;
      case SupportPriority.high:
        return AppColors.priorityHigh;
      case SupportPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }

  Color get softBackgroundColor {
    switch (this) {
      case SupportPriority.low:
        return AppColors.priorityLowSoft;
      case SupportPriority.moderate:
        return AppColors.priorityModerateSoft;
      case SupportPriority.high:
        return AppColors.priorityHighSoft;
      case SupportPriority.urgent:
        return AppColors.priorityUrgentSoft;
    }
  }

  /// Dignified, calm victim-facing status phrasing avoiding clinical labels.
  String get victimFacingStatus {
    switch (this) {
      case SupportPriority.low:
        return 'Your responses are logged. Everything looks steady.';
      case SupportPriority.moderate:
        return 'Thank you for checking in. Resources are always available.';
      case SupportPriority.high:
        return 'A follow-up has been gently recommended.';
      case SupportPriority.urgent:
        return 'Your request is prioritized. Dedicated assistance is available.';
    }
  }
}
