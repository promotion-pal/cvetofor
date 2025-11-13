import 'package:flutter/material.dart';
import 'dart:math';

Widget loadingScreen() {
  return Container(
    color: Colors.white,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [JumpingIcon()],
      ),
    ),
  );
}

class JumpingIcon extends StatefulWidget {
  @override
  _JumpingIconState createState() => _JumpingIconState();
}

class _JumpingIconState extends State<JumpingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> _randomWords = [
    'Ищем лучшие цветы...',
    'Собираем букет...',
    'Секундочку...',
    'Подбираем композицию...',
    'Почти готово...',
    'Обновляем каталог...',
    'Загружаем красоту...',
    'Соединяем с сервером...',
    'Подготавливаем данные...',
  ];

  String _currentText = 'Загрузка...';
  final Random _random = Random();
  bool _wasAtTop = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 0.0, end: -20.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        )..addListener(() {
          if (_animation.value <= -19.0 && !_wasAtTop) {
            _wasAtTop = true;
          } else if (_animation.value >= -1.0 && _wasAtTop) {
            _wasAtTop = false;
            _changeText();
          }
        });
  }

  void _changeText() {
    setState(() {
      String newText;
      do {
        newText = _randomWords[_random.nextInt(_randomWords.length)];
      } while (newText == _currentText && _randomWords.length > 1);

      _currentText = newText;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: child,
            );
          },
          child: Image.asset(
            'assets/icon/logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 24),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          child: Text(
            _currentText,
            key: ValueKey<String>(_currentText), // Ключ для анимации
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
