import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePopup {
  static Future<bool> shouldShowPopup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showWelcomePopup') ?? true;
  }

  static Future<void> setShowPopup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWelcomePopup', value);
  }

  static void show(BuildContext context) {
    bool dontShowAgain = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : const Color(0xFFF5F5F5),
          title: const Text(
            '🎂 Selamat menikmati aplikasi gabut ini !!',
            style: TextStyle(color: Color(0xFFD32F2F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pembuat: GustyxPower (Gusti)',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                ),
              ),
              Text(
                'Alasan: Gabut aja sebenernya wkwkw',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: dontShowAgain,
                    onChanged: (value) {
                      setState(() => dontShowAgain = value!);
                    },
                    activeColor: const Color(0xFFD32F2F),
                  ),
                  const Text('Jangan tampilkan lagi'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (dontShowAgain) {
                  await setShowPopup(false);
                }
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}