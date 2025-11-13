class AppConstants {
  static const String baseUrl = 'https://цветофор.рф';

  static const String homeEndpoint = '/';
  static const String cartEndpoint = '/cart';
  static const String profileEndpoint = '/profile';
  static const String loginEndpoint = '/login';

  static String get homeUrl => baseUrl + homeEndpoint;
  static String get cartUrl => baseUrl + cartEndpoint;
  static String get profileUrl => baseUrl + profileEndpoint;
}
