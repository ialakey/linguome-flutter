import 'package:flutter/material.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/entities/full_page.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/screens/main_screen.dart';
import 'package:linguome/screens/page_screen.dart';
import 'package:linguome/services/handler_processing_service.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AddTextScreen extends StatefulWidget {
  @override
  _AddTextScreenState createState() => _AddTextScreenState();
}

class _AddTextScreenState extends State<AddTextScreen> {
  TextEditingController _textEditingController = TextEditingController();
  HandlerProcessingService imageProcessingService = HandlerProcessingService();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('${AppConfig.assetsIcons}arrow-left.png', width: 24, height: 24),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
        title: Text(AppLocalizations.of(context)!.translate('addText')),
        actions: [
          TextButton(
            child: Text(
              AppLocalizations.of(context)!.translate('save'),
              style: TextStyle(
                color: AppColors.textColorBlack,
                fontFamily: 'Inter',
              ),
            ),
            onPressed: () async {
              String enteredText = _textEditingController.text;
              FullPage? createdPage = await imageProcessingService.createFullPage(enteredText, context);

              if (createdPage != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageScreen(
                      title: createdPage.pageLinguome.title,
                      vocabList: createdPage.items,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextFormField(
                controller: _textEditingController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.translate('pasteTextHere'),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}