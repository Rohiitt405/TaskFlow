import 'package:flutter/material.dart';

class SnackBarHelper {
  const SnackBarHelper._();

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: duration, action: action),
      );
  }
}
