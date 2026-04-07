import 'dart:async';
import 'package:cvetofor/core/conts.dart';
import 'package:cvetofor/shared/error.dart';
import 'package:cvetofor/core/themes.dart';
import 'package:cvetofor/core/web-utils.dart';
import 'package:cvetofor/shared/cart.dart';
import 'package:cvetofor/shared/loading.dart';
import 'package:cvetofor/shared/sorter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() => runApp(
  MaterialApp(
    title: 'Цветофор',
    theme: AppTheme.lightTheme,
    home: const Cvetofor(),
    locale: const Locale('ru', 'RU'),
    debugShowCheckedModeBanner: false,
  ),
);

class Cvetofor extends StatefulWidget {
  const Cvetofor({super.key});

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Cvetofor> {
  late final WebViewController _webViewController;
  late final SearchService _searchService;
  late final CartUtils _cartUtils;
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMsg = 'Нет подключения к интернету';
  bool _isOnline = true;
  int _cartItemCount = 0;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final List<String> _endpoints = ['', 'cart', 'profile'];
  final List<String> _pageTitles = ['Главная', 'Корзина', 'Профиль'];

  @override
  void initState() {
    super.initState();
    _cartUtils = CartUtils(
      onItemAdded: _showCartNotification,
      onCartCountUpdated: _updateCartCount,
    );
    _initializeWebView();
    _startConnectivityCheck();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _startConnectivityCheck() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final isOnline =
          results.isNotEmpty && results.first != ConnectivityResult.none;
      if (_isOnline != isOnline) {
        setState(() {
          _isOnline = isOnline;
        });

        if (isOnline && _hasError) {
          _reloadPage();
        }
      }
    });
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'FlutterCart',
        onMessageReceived: (JavaScriptMessage message) {
          _cartUtils.handleAddItem(message.message);
        },
      )
      ..addJavaScriptChannel(
        'FlutterCartCounter',
        onMessageReceived: (JavaScriptMessage message) {
          _cartUtils.handleCartCount(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) async {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });

            await WebViewUtils.acceptSiteCookies(_webViewController);
            await WebViewUtils.hideSiteCookieBanner(_webViewController);
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });

            _updateNavigationIndex(url);

            if (defaultTargetPlatform == TargetPlatform.iOS) {
              await WebViewUtils.hideSiteUi(_webViewController);
            }

            await WebViewUtils.hideSiteUi(_webViewController);
            await WebViewUtils.injectCartListener(_webViewController);
            await CartUtils.injectCartCounterListener(_webViewController);
          },
          onWebResourceError: (WebResourceError error) {
            _handleWebResourceError(error);

            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onUrlChange: (UrlChange urlChange) {
            if (urlChange.url != null) {
              _updateNavigationIndex(urlChange.url!);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('${AppConstants.baseUrl}/'));

    _searchService = SearchService(
      controller: _webViewController,
      baseUrl: AppConstants.baseUrl,
    );
  }

  void _handleWebResourceError(WebResourceError error) {
    print('=== WEBVIEW ERROR DETAILS ===');
    print('Error Type: ${error.runtimeType}');
    print('Error Code: ${error.errorCode}');
    print('Description: ${error.description}');
    print('URL: ${error.url}');
    print('=============================');

    switch (error.errorCode) {
      case -1:
        _errorMsg = 'Произошла неизвестная ошибка';
        break;

      case -2:
      case -1003:
        _errorMsg = 'Проверьте подключение к интернету';
        break;

      case -1004:
      case -6:
        _errorMsg = 'Сервис временно недоступен. Ведутся технические работы.';
        break;

      case -10:
      case -1002:
        _errorMsg = 'Страница не найдена';
        break;
    }
  }

  void _updateCartCount(int count) {
    setState(() {
      _cartItemCount = count;
    });
  }

  void _showSearchDialog() {
    SearchService.showSearchDialog(
      context: context,
      onSearch: _performSearch,
      baseUrl: AppConstants.baseUrl,
    );
  }

  void _performSearch(String query) {
    _searchService.searchFlowers(
      query,
      onLoading: () {
        setState(() {
          _isLoading = true;
        });
      },
    );
  }

  void _updateNavigationIndex(String url) {
    final uri = Uri.parse(url);
    final currentPath = uri.path.toLowerCase();

    int detectedIndex = 0;

    if (currentPath == '/' || currentPath.isEmpty) {
      detectedIndex = 0;
    } else if (currentPath.contains('cart')) {
      detectedIndex = 1;
    } else if (currentPath.contains('profile') ||
        currentPath.contains('login')) {
      detectedIndex = 2;
    }

    if (detectedIndex != _currentIndex) {
      setState(() {
        _currentIndex = detectedIndex;
      });
      print('🔄 Навигация обновлена: $currentPath -> $detectedIndex');
    }
  }

  void _onNavigationItemTapped(int index) {
    final targetUrl = '${AppConstants.baseUrl}/${_endpoints[index]}';

    if (index == _currentIndex) {
      _webViewController.loadRequest(Uri.parse(targetUrl));
      return;
    }

    setState(() {
      _currentIndex = index;
      _isLoading = true;
    });

    print('🎯 Переход на вкладку $index: $targetUrl');
    _webViewController.loadRequest(Uri.parse(targetUrl));
  }

  void _reloadPage() {
    if (!_isOnline) return;

    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _webViewController.reload();
  }

  void _showCartNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Товар добавлен в корзину'),
            const Icon(Icons.shopping_cart, color: Colors.white),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildWebView() {
    if (!_isOnline || _hasError) {
      return buildNoInternetWidget(onRetry: _reloadPage, errorMsg: _errorMsg);
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
      ],
    );
  }

  Widget _buildCartIconWithBadge() {
    return Stack(
      children: [
        const Icon(Icons.shopping_cart_outlined),
        if (_cartItemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _cartItemCount > 99 ? '99+' : '$_cartItemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCartSelectedIconWithBadge() {
    return Stack(
      children: [
        const Icon(Icons.shopping_cart),
        if (_cartItemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _cartItemCount > 99 ? '99+' : '$_cartItemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileIcon(bool isSelected) {
    return Icon(isSelected ? Icons.person : Icons.person_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Поиск цветов',
          ),
        ],
      ),
      body: _isLoading ? loadingScreen() : _buildWebView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationItemTapped,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: _buildCartIconWithBadge(),
            selectedIcon: _buildCartSelectedIconWithBadge(),
            label: 'Корзина',
          ),
          NavigationDestination(
            icon: _buildProfileIcon(false),
            selectedIcon: _buildProfileIcon(true),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
