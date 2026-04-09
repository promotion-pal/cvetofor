import 'package:cvetofor/shared/config.dart';
import 'package:flutter/material.dart';

class PrivacyDetailsScreen extends StatefulWidget {
  const PrivacyDetailsScreen({super.key});

  @override
  _PrivacyDetailsScreenState createState() => _PrivacyDetailsScreenState();
}

class _PrivacyDetailsScreenState extends State<PrivacyDetailsScreen> {
  final List<Map<String, dynamic>> _privacyItems = [
    {
      'icon': Icons.analytics,
      'iconColor': Colors.blue,
      'title': 'Яндекс.Метрика',
      'description':
          'Запрашиваемые данные: IP-адрес, тип устройства, операционная система, браузер, разрешение экрана, язык, часовой пояс, просматриваемые страницы, клики, скроллы, время на сайте, глубина просмотра, уникальный идентификатор пользователя (_ym_uid), идентификатор сессии (_ym_d), источник перехода, геолокация (город, регион)',
    },
    {
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
      'title': 'Сохранение вашего согласия',
      'description':
          'После того как вы нажмёте «Принять и продолжить», ваше согласие будет сохранено на устройстве. При следующем запуске приложение не будет показывать этот экран повторно.',
    },
    {
      'icon': Icons.shopping_cart,
      'iconColor': Colors.green,
      'title': 'Cookies корзины',
      'description':
          'Сохраняем ID товаров, количество, размеры, цены и состав заказа. Без этих данных корзина будет очищаться после каждого закрытия приложения.',
    },
    {
      'icon': Icons.person,
      'iconColor': Colors.blue,
      'title': 'Данные авторизации',
      'description':
          'При входе в аккаунт сохраняем: email, телефон, имя, адрес доставки, историю заказов, список избранного, промокоды. Это нужно, чтобы вы не вводили данные каждый раз и могли видеть свои заказы. Все данные передаются по HTTPS и хранятся на защищённых серверах.',
    },
    {
      'icon': Icons.analytics_outlined,
      'iconColor': Colors.orange,
      'title': 'Цель сбора',
      'description':
          'Анализировать популярные категории и товары, отслеживать ошибки и зависания, измерять скорость загрузки страниц, понимать, где пользователи сталкиваются с трудностями, тестировать новые функции, улучшать интерфейс и делать рекомендации.',
    },
    {
      'icon': Icons.business,
      'iconColor': Colors.purple,
      'title': 'Кто обрабатывает',
      'description':
          'ООО «Яндекс» (ИНН 7736207543). Сертификат соответствия требованиям 152-ФЗ. Данные хранятся на серверах в РФ. Мы не передаём данные третьим лицам и не используем их для таргетированной рекламы.',
    },
    {
      'icon': Icons.security,
      'iconColor': Colors.teal,
      'title': 'Как мы защищаем данные',
      'description':
          'Передача данных по HTTPS с шифрованием TLS 1.2/1.3. Доступ к сырым данным только у ограниченного круга сотрудников. Агрегированные данные обезличиваются перед анализом.',
    },
    {
      'icon': Icons.email,
      'iconColor': Colors.red,
      'title': 'Контакты для вопросов',
      'description':
          'По всем вопросам обработки данных: ${AppConfig.companyName}, ${AppConfig.supportEmail}, ${AppConfig.supportPhone}. Ответим в течение 3 рабочих дней.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конфиденциальность'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ..._privacyItems.map((item) => _buildPrivacyItem(item)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item['iconColor'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item['icon'], color: item['iconColor'], size: 24),
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  item['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
