import 'package:flutter/material.dart';

Widget buildNoInternetWidget({required VoidCallback onRetry}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Нет подключения к интернету',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          'Проверьте подключение и попробуйте снова',
          textAlign: TextAlign.center,
          // style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Повторить'),
        ),
      ],
    ),
  );
}
