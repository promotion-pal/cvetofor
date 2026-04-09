import 'package:cvetofor/app.dart';
import 'package:cvetofor/shared/privacy_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  _PrivacyScreen createState() => _PrivacyScreen();
}

class _PrivacyScreen extends State<PrivacyScreen> {
  bool _isLoading = false;

  void navigateToPrivacyDetailsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyDetailsScreen()),
    );
  }

  Future<void> navigateToCvetofor(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_consent_given', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Cvetofor()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icon/logo.png', width: 120, height: 120),
              const SizedBox(height: 40),

              Text(
                'Добро пожаловать!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 48),

              Column(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Конфиденциальность',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Мы используем cookies и аналитику. Это помогает корзине работать, а нам — улучшать приложение.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => navigateToPrivacyDetailsScreen(context),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Подробнее о данных'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => navigateToCvetofor(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Принять и продолжить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
