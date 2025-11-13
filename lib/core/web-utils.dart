import 'package:webview_flutter/webview_flutter.dart';

class WebViewUtils {
  static bool _cookiesAccepted = false;

  static Future<void> hideSiteUi(WebViewController controller) async {
    const hideScript = '''
(function() {
  const hideElements = (selector) => {
    document.querySelectorAll(selector).forEach(el => {
      el.style.cssText = 'display:none!important;visibility:hidden!important;height:0!important;';
    });
  };
  
  const selectors = [
    'header', 'footer', 'nav', '.header', '.footer', '.navbar',
    '.site-header', '.site-footer', '.main-nav', '.breadcrumbs',
    '.ads', '.ad-container', '.social-share', '.social-floating', '.floating-buttons', '.social-icon',
    '.category_description', '.modal_cookie', '.return-to-mainpage-button',
    '[data-modal="notification-added-to-cart"]'
  ];
  
  selectors.forEach(hideElements);
  
  document.body.style.paddingTop = '0';
  document.body.style.paddingBottom = '0';
})();
''';

    try {
      await controller.runJavaScript(hideScript);
    } catch (e) {
      print('Ошибка при скрытии UI сайта: $e');
    }
  }

  static Future<void> acceptSiteCookies(WebViewController controller) async {
    if (_cookiesAccepted) return;

    const String acceptCookiesScript = '''
    document.cookie = "laravel_cookie_consent=1; path=/; max-age=31536000; samesite=lax";

    localStorage.setItem('cookie_consent', 'accepted');
    localStorage.setItem('laravel_cookie_consent', '1');

    console.log('Cookie consent accepted automatically');
  ''';

    try {
      await controller.runJavaScript(acceptCookiesScript);
      _cookiesAccepted = true;
      print('Site cookies accepted automatically');
    } catch (e) {
      print('Error accepting site cookies: $e');
    }
  }

  static Future<void> hideSiteCookieBanner(WebViewController controller) async {
    const String hideBannerScript = '''
    (function() {
      // Скрываем элементы по классам и ID
      const selectors = [
        '.cookie-consent',
        '.cookie-banner',
        '.cookies-banner',
        '#cookie-consent',
        '#cookie-banner',
        '#cookies-banner',
        '.gdpr-banner',
        '#gdpr-banner',
        '.js-cookie-consent',
        '.js-cookie-banner',
        '.modal_cookie',
        '.cookie-notice',
        '#cookie-notice',
        '[class*="cookie"]',
        '[id*="cookie"]',
        '[class*="Cookie"]',
        '[id*="Cookie"]'
      ];

      let hiddenCount = 0;
      selectors.forEach(selector => {
        const elements = document.querySelectorAll(selector);
        elements.forEach(el => {
          if (el.offsetParent !== null) { // Проверяем, что элемент видим
            el.style.cssText = 'display: none !important; visibility: hidden !important; opacity: 0 !important; height: 0 !important; padding: 0 !important; margin: 0 !important; position: absolute !important;';
            hiddenCount++;
          }
        });
      });

      // Дополнительно ищем по тексту (только для небольших элементов)
      const textSelectors = ['div', 'section', 'aside', 'dialog'];
      textSelectors.forEach(tag => {
        const elements = document.querySelectorAll(tag);
        elements.forEach(el => {
          const text = el.textContent || '';
          const hasCookieText = text.includes('cookie') ||
                               text.includes('Cookie') ||
                               text.includes('куки') ||
                               text.includes('Куки') ||
                               text.includes('COOKIE');

          if (hasCookieText && text.length < 1000 && el.offsetParent !== null) {
            el.style.cssText = 'display: none !important; visibility: hidden !important; opacity: 0 !important;';
            hiddenCount++;
          }
        });
      });

      console.log('Hidden ' + hiddenCount + ' cookie banner elements');

      try {
        if (typeof window.hideCookieBanner === 'function') {
          window.hideCookieBanner();
        }
        if (typeof window.acceptAllCookies === 'function') {
          window.acceptAllCookies();
        }
        if (typeof window.closeCookieBanner === 'function') {
          window.closeCookieBanner();
        }
      } catch (e) {
        // Игнорируем ошибки в функциях
      }
    })();
  ''';

    try {
      await controller.runJavaScript(hideBannerScript);
      print('Site cookie banner hidden');
    } catch (e) {
      print('Error hiding site cookie banner: $e');
    }
  }

  static Future<void> injectCartListener(WebViewController controller) async {
    const cartListenerScript = '''
    function setupCartTracking() {
      
      document.addEventListener('click', function(event) {
        const target = event.target;
        
        const cartButton = target.closest([
          '.add-product-to-cart-button',
          '[class*="add-to-cart"]',
          '[class*="add_to_cart"]',
          '.btn-cart',
          '.product-buy',
          'button[onclick*="cart"]',
          'button[onclick*="addToCart"]'
        ].join(','));
        
        if (cartButton) {          
          try {
            const productName = target.closest('.product, .item, .card')?.querySelector('[class*="name"], [class*="title"]')?.textContent || 'Товар';
            const productPrice = target.closest('.product, .item, .card')?.querySelector('[class*="price"], [class*="cost"]')?.textContent || '';
            
            FlutterCart.postMessage(JSON.stringify({
              type: 'item_added_detailed',
              product: productName.trim(),
              price: productPrice.trim(),
              timestamp: new Date().toISOString(),
              element: cartButton.className
            }));
          } catch (e) {
            console.log('ℹ️ Не удалось получить детали товара:', e);
            FlutterCart.postMessage('item_added_basic');
          }
        }
      });
    }
    
    setupCartTracking();
    console.log('✅ Cart tracking activated');
  ''';

    try {
      await controller.runJavaScript(cartListenerScript);
      print('✅ Cart listener внедрен для add-product-to-cart-button');
    } catch (e) {
      print('❌ Ошибка внедрения cart listener: $e');
    }
  }

  Future<void> goBackNavigation(WebViewController controller) async {
    if (await controller.canGoBack()) {
      await controller.goBack();
    }
  }

  Future<void> goForwardNavigation(WebViewController controller) async {
    if (await controller.canGoForward()) {
      await controller.goForward();
    }
  }
}
