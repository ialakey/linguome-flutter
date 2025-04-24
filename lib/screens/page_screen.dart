import 'package:flutter/material.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/entities/item.dart';
import 'package:linguome/screens/main_screen.dart';
import 'package:linguome/widgets/vocab_card.dart';
import 'package:quickalert/quickalert.dart';

class PageScreen extends StatefulWidget {
  final String title;
  final List<Item> vocabList;

  PageScreen({required this.title, required this.vocabList});

  @override
  _PageScreenState createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {

  List<Item> filteredList = [];
  late List<String> vocabList;

  void initState() {
    super.initState();
    vocabList = [];
    filteredList = widget.vocabList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset('${AppConfig.assetsIcons}arrow-left.png', width: 24, height: 24),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset('${AppConfig.assetsIcons}interrogation.png', width: 24, height: 24),
            onPressed: () {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.info,
                text: 'Definition for ${widget.title}',
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return VocabCard(
                  title: filteredList[index].word,
                  description: filteredList[index].definition,
                  pos: filteredList[index].pos,
                  initialStatus: filteredList[index].status,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}