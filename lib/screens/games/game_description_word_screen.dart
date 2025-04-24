import 'package:flutter/material.dart';
import 'package:linguome/entities/word_vocabulary.dart';
import 'dart:math' as math;

import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/screens/games/games_screen.dart';
import 'package:linguome/screens/home_screen.dart';
import 'package:linguome/services/handler_processing_service.dart';
import 'package:linguome/widgets/bottom_navigation.dart';
import 'package:linguome/widgets/custom_loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class GameDescriptionWordScreen extends StatefulWidget {
  @override
  _GameDescriptionWordScreenState createState() => _GameDescriptionWordScreenState();
}

class _GameDescriptionWordScreenState extends State<GameDescriptionWordScreen> with TickerProviderStateMixin{
  bool _isFlipped = false;
  late AnimationController _controller;
  late AnimationController _swipeLeftController;
  late AnimationController _swipeRightController;

  late List<WordVocabulary> _words = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _swipeLeftController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _swipeRightController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _loadWordData();
  }

  void _loadWordData() async {
    _words = await HandlerProcessingService().fetchVocabulary(100, 1, null, null, "on-study");
    if (_words.isNotEmpty) {
      setState(() {
        _isLoading = false;
        _words.shuffle();
        if (_words.length > 10) {
          _words = _words.sublist(0, 10);
        }
      });
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        text: AppLocalizations.of(context)!.translate("addAWordToFavoritesToStartTheGame"),
      ).then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigation(initialIndex: 3,)),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _swipeLeftController.dispose();
    _swipeRightController.dispose();
    super.dispose();
  }

  void _handleSwipeLeft() {
    _swipeLeftController.forward();
    if (_currentIndex >= _words.length - 1) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isFlipped = false;
        _currentIndex = (_currentIndex + 1) % _words.length;
      });
      _controller.reverse();
    }
  }

  void _handleSwipeRight(String word, String pos) {
    _swipeRightController.forward();
    if (_currentIndex >= _words.length - 1) {
      setState(() {
        _isFlipped = false;
        _currentIndex = (_currentIndex + 1) % _words.length;
        HandlerProcessingService().addWordToVocabulary(word, pos, "known");
      });
      Navigator.pop(context);
    } else {
      setState(() {
        _isFlipped = false;
        _currentIndex = (_currentIndex + 1) % _words.length;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('wordGame')),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigation(initialIndex: 3,)),
            );
          },
        ),
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildGameScreen(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CustomLoadingIndicator(),
    );
  }

  Widget _buildGameScreen() {
    _swipeLeftController.reset();
    _swipeRightController.reset();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${_currentIndex + 1}/${_words.length}',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
            ),
          ),
            SizedBox(height: 70,),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.background,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _words[_currentIndex].definition,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isFlipped = !_isFlipped;
                  if (_isFlipped) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                });
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final angle = _controller.value * math.pi;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: SizedBox(
                      width: 200,
                      height: 300,
                      child: Stack(
                        children: [
                          Visibility(
                            visible: !_isFlipped,
                            child: Card(
                              color: Theme.of(context).colorScheme.background,
                              elevation: 3,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isFlipped = true;
                                    _controller.forward();
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text(
                                    AppLocalizations.of(context)!.translate('showWord'),
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 24
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _isFlipped,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset.zero,
                                end: Offset(1, 0),
                              ).animate(_swipeRightController),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset.zero,
                                  end: Offset(-1, 0),
                                ).animate(_swipeLeftController),
                                child: Card(
                                  elevation: 3,
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    alignment: Alignment.center,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: Text(
                                        _words[_currentIndex].word,
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 24
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _handleSwipeLeft,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Icon(Icons.thumb_down, color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: () => _handleSwipeRight(_words[_currentIndex].word, _words[_currentIndex].pos),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Icon(Icons.thumb_up, color: Colors.white),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}