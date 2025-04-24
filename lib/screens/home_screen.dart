import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/entities/item.dart';
import 'package:linguome/entities/page.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/screens/page_screen.dart';
import 'package:linguome/services/format_service.dart';
import 'package:linguome/services/handler_processing_service.dart';
import 'package:linguome/widgets/custom_loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PageLinguome> _pages = [];
  Map<String, List<Item>> _itemsMap = {};
  HandlerProcessingService handleProcessingService = HandlerProcessingService();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPages();
  }

  Future<void> _loadPages() async {
    final List<String>? pagesJson = _prefs.getStringList('pages');
    if (pagesJson != null) {
      setState(() {
        _pages = pagesJson.map((json) => PageLinguome.fromJson(jsonDecode(json))).toList();
      });
    }
    _fetchPages();
  }

  Future<void> _fetchPages() async {
    try {
      final List<PageLinguome> pages = await handleProcessingService.fetchPages();
      setState(() {
        _pages = pages;
        _savePages();
      });
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: AppLocalizations.of(context)!.translate('oops'),
          text: AppLocalizations.of(context)!.translate('failedToFetchPage'),
        );
      }
    }
  }

  Future<void> _savePages() async {
    final List<String> pagesJson = _pages.map((page) => jsonEncode(page.toJson())).toList();
    await _prefs.setStringList('pages', pagesJson);
  }

  Future<void> _fetchAndSaveItems(String pageId) async {
    if (_itemsMap[pageId] == null) {
      try {
        final List<Item> items = await handleProcessingService.fetchItems(pageId);
        final List<String> itemsJson = items.map((item) => jsonEncode(item.toJson())).toList();
        await _prefs.setStringList('items_$pageId', itemsJson);
        setState(() {
          _itemsMap[pageId] = items;
        });
      } catch (e) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: AppLocalizations.of(context)!.translate('error'),
          text: AppLocalizations.of(context)!.translate('errorFetchData'),
        );
      }
    }
  }

  Future<List<Item>> _loadItems(String pageId) async {
    if (_itemsMap[pageId] != null) {
      return _itemsMap[pageId]!;
    } else {
      final List<String>? itemsJson = _prefs.getStringList('items_$pageId');
      if (itemsJson != null) {
        final List<Item> items = itemsJson.map((json) => Item.fromJson(jsonDecode(json))).toList();
        setState(() {
          _itemsMap[pageId] = items;
        });
        return items;
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('pagesYouRead'),
          style: TextStyle(
            fontFamily: 'Inter',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPages,
        color: Colors.blueAccent,
        child: _buildPageList(),
      ),
    );
  }

  Widget _buildPageList() {
    if (_pages.isEmpty) {
      return Center(
        child: _pages.isEmpty
            ? Text(
          AppLocalizations.of(context)!.translate('createYourFirstPageInEnglish'),
          style: TextStyle(
            color: AppColors.textColorBlack,
            fontFamily: 'Inter',
            fontSize: 18,
          ),
        )
            : CustomLoadingIndicator(),
      );
    } else {
      return ListView.builder(
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          final page = _pages[index];
          return Dismissible(
            key: Key(page.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: AppColors.deleteBackgroundColor,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              child: Image.asset('${AppConfig.assetsIcons}trash.png', width: 24, height: 24),
            ),
            confirmDismiss: (direction) async {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.confirm,
                text: AppLocalizations.of(context)!.translate('deleteQuestion'),
                confirmBtnText: AppLocalizations.of(context)!.translate('yes'),
                cancelBtnText: AppLocalizations.of(context)!.translate('no'),
                onConfirmBtnTap: () {
                  setState(() {
                    _pages.removeAt(index);
                  });
                  _deletePage(page.id);
                  Navigator.of(context).pop(true);
                },
                onCancelBtnTap: () {
                  Navigator.of(context).pop(false);
                },
                confirmBtnColor: AppColors.confirmBtnColor,
              );
              return null;
            },
            onDismissed: (direction) {
              setState(() {
                _pages.removeAt(index);
              });
              _deletePage(page.id);
            },
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.background,
              child: ListTile(
                title: Text(
                  page.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: AppColors.textColorBlack,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  FormatService.formatDateString(page.createdAt),
                  style: TextStyle(
                    color: AppColors.textColorBlack,
                    fontFamily: 'Inter',
                    fontSize: 12,
                  ),
                ),
                onTap: () async {
                  final String pageId = page.id;
                  List<Item> itemList = _itemsMap[pageId] ?? await _loadItems(pageId);
                  if (itemList.isEmpty) {
                    await _fetchAndSaveItems(pageId);
                    itemList = _itemsMap[pageId] ?? [];
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PageScreen(
                        title: page.title,
                        vocabList: itemList,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _deletePage(String pageId) async {
    try {
      await handleProcessingService.deletePage(pageId);
      setState(() {
        _fetchPages();
      });
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: AppLocalizations.of(context)!.translate('oops'),
        text: AppLocalizations.of(context)!.translate('failedToDeletePage'),
      );
    }
  }
}