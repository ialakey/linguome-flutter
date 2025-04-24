import 'package:flutter/material.dart';
import 'package:linguome/config/app_colors.dart';

class GameCard extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const GameCard({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  color: AppColors.textColorBlack,
                  fontSize: 18,
                  fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ),
    );
  }
}