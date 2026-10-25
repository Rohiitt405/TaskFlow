import 'dart:async';
import 'package:flutter/material.dart';

class SnackBarHelper {
  const SnackBarHelper._();

  static Timer? _dismissTimer;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    _dismissTimer?.cancel();

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
        ),
      );

    _dismissTimer = Timer(duration, () {
      messenger.hideCurrentSnackBar();
    });
  }
}
