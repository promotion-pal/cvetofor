import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SearchService {
  final WebViewController controller;
  final String baseUrl;

  SearchService({required this.controller, required this.baseUrl});

  Future<void> searchFlowers(String query, {VoidCallback? onLoading}) async {
    if (query.trim().isEmpty) return;

    onLoading?.call();

    try {
      String searchUrl = '$baseUrl/search?q=${Uri.encodeComponent(query)}';
      await controller.loadRequest(Uri.parse(searchUrl));
    } catch (e) {
      print('❌ Ошибка поиска: $e');
    }
  }

  static void showSearchDialog({
    required BuildContext context,
    required Function(String) onSearch,
    required String baseUrl,
  }) {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(onSearch: onSearch, baseUrl: baseUrl),
    );
  }
}

class _SearchDialog extends StatefulWidget {
  final Function(String) onSearch;
  final String baseUrl;

  const _SearchDialog({required this.onSearch, required this.baseUrl});

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(query);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Поиск',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                    color: Colors.grey,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Розы, тюльпаны, хризантемы...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCA4492)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: const Color(0xFFCA4492)),
                    onPressed: _performSearch,
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
