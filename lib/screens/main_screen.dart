import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:linguome/widgets/bottom_navigation.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Intro(
                padding: EdgeInsets.zero,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                maskColor: const Color.fromRGBO(0, 0, 0, .6),
                child: BottomNavigation(initialIndex: 0,)),
          ),
        ],
      ),
    );
  }
}
