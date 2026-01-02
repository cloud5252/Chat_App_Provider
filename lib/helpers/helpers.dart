import 'package:flutter/material.dart';

void showNoInternetDialog(context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        "No Internet Connection",
        style: TextStyle(fontSize: 20),
      ),
      content: const Text(
        "Please check your internet connection and try again.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
