import 'package:flutter/material.dart';

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          message,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.red,
    ),
  );
}
void showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          message,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.green,
    ),
  );
}