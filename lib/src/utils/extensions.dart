import 'package:flutter/material.dart';

/// extension to get responsive width/height values
extension CustomContext on BuildContext {
  /// return the calculated value relative to device screen height
  double screenHeight([double percent = 1]) =>
      MediaQuery.of(this).size.height * percent;

  /// return value relative to screen width
  double screenWidth([double percent = 1]) =>
      MediaQuery.of(this).size.width * percent;
}
