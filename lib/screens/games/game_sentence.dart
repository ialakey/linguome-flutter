import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/widgets/custom_loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

import 'test_result_screen.dart';

class EnglishLearningGame extends StatefulWidget {
  @override
  _EnglishLearningGameState createState() => _EnglishLearningGameState();
}

class _EnglishLearningGameState extends State<EnglishLearningGame> {
  List<Map<String, dynamic>> _sentences = [];
  int _currentIndex = 0;
  String _selectedAnswer = '';
  List<bool?> _answers = [];
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSentences();
  }

  void _loadSentences() async {
    String jsonString = await rootBundle.loadString('assets/games_data/sentences.json');
    List<dynamic> decodedJson = json.decode(jsonString);
    List<Map<String, dynamic>> sentencesList = List<Map<String, dynamic>>.from(decodedJson);

    List<int> randomIndexes = List<int>.generate(sentencesList.length, (index) => index);
    randomIndexes.shuffle();

    List<Map<String, dynamic>> randomSentences = [];
    for (int i = 0; i < 10; i++) {
      randomSentences.add(sentencesList[randomIndexes[i]]);
    }

    setState(() {
      _sentences = randomSentences;
      _answers = List<bool?>.filled(_sentences.length, null);
    });
  }

  void _nextSentence() {
    if (_currentIndex < _sentences.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = '';
      });
    } else {
      int score = _answers.where((answer) => answer != null && answer!).length;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestResultScreen(score),
        ),
      );
    }
  }

  void _checkAnswer() {
    String userAnswer = _textEditingController.text.trim().toLowerCase();
    String correctAnswer = _sentences[_currentIndex]['correctAnswer'].toLowerCase();

    bool isCorrect = userAnswer == correctAnswer || _selectedAnswer == correctAnswer;

    setState(() {
      _answers[_currentIndex] = isCorrect;
    });

    _showResultDialog(isCorrect);
  }

  void _showResultDialog(bool isCorrect) {
    QuickAlert.show(
      context: context,
      type: isCorrect ? QuickAlertType.success : QuickAlertType.error,
      title: isCorrect ? '${AppLocalizations.of(context)!.translate('correct')}!'
          : '${AppLocalizations.of(context)!.translate('incorrect')}!',
      text: isCorrect
          ? '${AppLocalizations.of(context)!.translate('wellDone')}!'
          : '${AppLocalizations.of(context)!.translate('theCorrectAnswerIs')}: ${_sentences[_currentIndex]['correctAnswer']}',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        if (isCorrect || _selectedAnswer.isNotEmpty) {
          _nextSentence();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('englishSentenceGame')),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _sentences.length,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            backgroundColor: Colors.grey[300],
          ),
          Expanded(
            child: Center(
              child: _sentences.isEmpty
                  ? CustomLoadingIndicator()
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      _sentences[_currentIndex]['sentence'].replaceAll('___', '_________'),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_sentences[_currentIndex]['options'] != null)
                    Column(
                      children: _sentences[_currentIndex]['options']
                          .map<Widget>((option) =>
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAnswer = option;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selectedAnswer == option
                                          ? Colors.blue
                                          : Colors.grey,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 12.0),
                                          child: Text(
                                            option,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 18.0,
                                              color: _selectedAnswer == option
                                                  ? Colors.blue
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ))
                          .toList(),
                    )
                  else
                    TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate('enterMissingWord'),
                      ),
                    ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _checkAnswer,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 34.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('check'),
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20.0,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}