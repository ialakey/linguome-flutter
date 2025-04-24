import 'dart:async';
import 'package:flutter/material.dart';
import 'package:linguome/entities/word_vocabulary.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/services/handler_processing_service.dart';
import 'package:linguome/widgets/custom_loading_indicator.dart';
import 'package:linguome/widgets/search_bar.dart';
import 'package:linguome/widgets/vocab_card.dart';
import 'package:quickalert/quickalert.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<WordVocabulary>> vocabFuture;
  late List<WordVocabulary> vocabList;
  late List<WordVocabulary> filteredList;
  late TextEditingController _controller;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  int _currentPage = 1;
  bool _hasMorePages = true;
  String? _sort;
  String? _status;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    vocabFuture = _fetchWords();
    vocabList = [];
    filteredList = [];
    _scrollController.addListener(_scrollListener);
  }

  Future<List<WordVocabulary>> _fetchWords([String? search, String? sort, String? status]) async {
    try {
      List<WordVocabulary> words = await HandlerProcessingService().fetchVocabulary(100, _currentPage, sort, search, status);
      setState(() {
        if (_currentPage == 1) {
          vocabList = words;
        } else {
          vocabList.addAll(words);
        }
        filteredList = List.from(vocabList);
        _hasMorePages = words.length == 100;
      });
      return words;
    } catch (error) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: AppLocalizations.of(context)!.translate('oops'),
        text: AppLocalizations.of(context)!.translate('errorLoadingWords'),
      );
      return [];
    }
  }

  void _fetchMoreWords() async {
    int nextPage = _currentPage + 1;
    List<WordVocabulary> nextPageData = await HandlerProcessingService().fetchVocabulary(100, nextPage, _sort, _controller.text, _status);
    setState(() {
      if (nextPageData.isNotEmpty) {
        vocabList.addAll(nextPageData);
        filteredList = List.from(vocabList);
        _currentPage = nextPage;
      }

      _hasMorePages = nextPageData.length == 100;
    });
  }


  void filterList(String searchText, String? sort, String? status) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () async {
      setState(() {
        _sort = sort;
        _status = status;
        _currentPage = 1;
      });
      await _fetchWords(searchText, sort, status);
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _hasMorePages) {
      _fetchMoreWords();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('search'),
          style: TextStyle(
            fontFamily: 'Inter',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SearchCustomBar(
            controller: _controller,
            filterList: filterList,
          ),
          Expanded(
            child: FutureBuilder<List<WordVocabulary>>(
              future: vocabFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CustomLoadingIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredList.length + (_hasMorePages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredList.length && _hasMorePages) {
                        return Center(
                          child: CustomLoadingIndicator(),
                        );
                      } else if (index < filteredList.length) {
                        return VocabCard(
                          title: filteredList[index].word,
                          description: filteredList[index].definition,
                          pos: filteredList[index].pos,
                          initialStatus: filteredList[index].status,
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}