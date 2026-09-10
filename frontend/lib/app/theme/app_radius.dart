import 'package:flutter/material.dart';

/// Standardized corner radius tokens for SAHAY-AI.
class AppRadius {
  AppRadius._();

  static const double small = 8.0;
  static const double button = 12.0;
  static const double input = 12.0;
  static const double card = 16.0;
  static const double large = 20.0;
  static const double dialog = 20.0;
  static const double pill = 999.0;

  static const BorderRadius smallBorderRadius = BorderRadius.all(Radius.circular(small));
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(button));
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius largeBorderRadius = BorderRadius.all(Radius.circular(large));
  static const BorderRadius dialogBorderRadius = BorderRadius.all(Radius.circular(dialog));
}
