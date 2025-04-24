import 'package:flutter/material.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/entities/word_definition.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/screens/vocab_details_screen.dart';
import 'package:linguome/services/handler_processing_service.dart';
import 'package:linguome/widgets/status_circle.dart';
import 'package:quickalert/quickalert.dart';

class VocabCard extends StatefulWidget {
  final String title;
  final String description;
  final String pos;
  final String initialStatus;

  const VocabCard({
    required this.title,
    required this.description,
    required this.pos,
    required this.initialStatus,
  });

  @override
  _VocabCardState createState() => _VocabCardState();
}

class _VocabCardState extends State<VocabCard> {
  List<WordDefinition> _definitionsList = [];
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _fetchDefinitions();
  }

  Future<void> _fetchDefinitions() async {
    try {
      final List<WordDefinition> definitions = await HandlerProcessingService().fetchWordDefinition(
        widget.title,
        widget.pos,
        true,
      );
      setState(() {
        _definitionsList = definitions;
      });
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: AppLocalizations.of(context)?.translate('oops') ?? 'Oops',
          text: AppLocalizations.of(context)?.translate('failedToFetchDefinition') ?? 'Failed to fetch definition',
        );
      }
    }
  }

  void _toggleStatus() async {
    String newStatus = "";

    switch (_status) {
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
      _status = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Card(
          color: Theme.of(context).colorScheme.background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VocabDetailsScreen(
                    title: widget.title,
                    description: widget.description,
                    pos: widget.pos,
                    definitionsList: _definitionsList,
                    initialStatus: _status,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorBlack,
                          ),
                        ),
                      ),
                      Text(
                        widget.pos,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: AppColors.textColorGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.description,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: AppColors.textColorBlack,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: StatusCircle(
                          currentStatus: _status,
                          onTap: _toggleStatus,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}