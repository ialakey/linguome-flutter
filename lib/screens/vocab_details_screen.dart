import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/entities/word_definition.dart';
import 'package:linguome/entities/word_vocabulary.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/services/handler_processing_service.dart';
import 'package:linguome/widgets/status_circle.dart';
import 'package:quickalert/quickalert.dart';

class VocabDetailsScreen extends StatefulWidget {
  final String title;
  final String description;
  final String pos;
  final List<WordDefinition> definitionsList;
  final String initialStatus;

  const VocabDetailsScreen({
    required this.title,
    required this.description,
    required this.pos,
    required this.definitionsList,
    required this.initialStatus,
  });

  @override
  _VocabDetailsScreenState createState() => _VocabDetailsScreenState();
}

class _VocabDetailsScreenState extends State<VocabDetailsScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
  }

  void _speakWord() async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage('en-US');
    await flutterTts.speak(widget.title);
  }

  void _toggleStatus() async {
    String newStatus = "";

    switch (_currentStatus) {
      case "new":
        newStatus = "on-study";
        break;
      case "on-study":
        newStatus = "known";
        break;
      case "known":
        newStatus = "new";
        break;
    }

    await HandlerProcessingService().addWordToVocabulary(
      widget.title,
      widget.pos,
      newStatus,
    );

    setState(() {
      _currentStatus = newStatus;
    });
  }

  List<Widget> _buildCocaBandCircles(int cocaBand) {
    List<Color> colors = [Colors.redAccent, Colors.redAccent, Colors.redAccent];

    if (cocaBand >= 1 && cocaBand <= 10) {
      colors[0] = Colors.black54;
    } else if (cocaBand > 10 && cocaBand <= 30) {
      colors[0] = Colors.black54;
      colors[1] = Colors.black54;
    } else if (cocaBand > 30 && cocaBand <= 40) {
      colors[0] = Colors.black54;
      colors[1] = Colors.black54;
      colors[2] = Colors.black54;
    }

    return List.generate(
      3,
          (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors[index],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Image.asset('${AppConfig.assetsIcons}arrow-left.png', width: 24, height: 24),
          onPressed: () {
            Navigator.of(context).pop(_currentStatus);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      // SizedBox(width: 10),
                      // Text(
                      //   '/kənˈsaɪs/',
                      //   style: TextStyle(fontSize: 16),
                      // ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: _speakWord,
                              icon: Image.asset('${AppConfig.assetsIcons}volume.png', width: 16, height: 16),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      StatusCircle(
                        currentStatus: _currentStatus,
                        onTap: _toggleStatus,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        widget.pos,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(width: 8),
                      if (widget.definitionsList.isNotEmpty && widget.definitionsList.first.cocaBand != null)
                        ..._buildCocaBandCircles(widget.definitionsList.first.cocaBand!),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: double.infinity,
                        child: Card(
                          color: AppColors.backgroundColor,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: widget.description.split(' ').map<TextSpan>((word) {
                                      return TextSpan(
                                        text: word + ' ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontFamily: 'Inter',
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            List<WordVocabulary> words = await HandlerProcessingService().fetchVocabulary(100, 1, null, word, null);
                                            if (words.isNotEmpty) {
                                              WordVocabulary firstWord = words[0];
                                              String pos = firstWord.pos;
                                              final List<WordDefinition> definitions = await HandlerProcessingService().fetchWordDefinition(
                                                word,
                                                pos,
                                                true,
                                              );
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => VocabDetailsScreen(
                                                    title: word,
                                                    description: firstWord.definition,
                                                    pos: pos,
                                                    definitionsList: definitions,
                                                    initialStatus: _currentStatus,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              QuickAlert.show(
                                                context: context,
                                                type: QuickAlertType.error,
                                                title: AppLocalizations.of(context)!.translate('oops'),
                                                text: AppLocalizations.of(context)!.translate('failedToFetchPage'),
                                              );
                                            }
                                          },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...widget.definitionsList.map((definition) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: double.infinity,
                            child: Card(
                              color: AppColors.backgroundColor,
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      definition.definition,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    if (definition.lexDomain.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          SizedBox(height: 4),
                                          Text(
                                            '${AppLocalizations.of(context)!.translate('lexicalDomain')}:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              definition.lexDomain,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (definition.synonyms.isNotEmpty) ...[
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${AppLocalizations.of(context)!.translate('synonyms')}: ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              definition.synonyms.join(', '),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}