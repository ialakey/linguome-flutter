import 'package:flutter/material.dart';
import 'package:linguome/localizations/app_localizations.dart';

class StatusCircle extends StatelessWidget {
  final String currentStatus;
  final VoidCallback onTap;

  const StatusCircle({
    required this.currentStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color fillColor;
    Color textColor;
    String statusLetter;

    switch (currentStatus) {
      case "on-study":
        borderColor = Colors.red;
        fillColor = Colors.red[100]!;
        textColor = Colors.red[900]!;
        statusLetter = AppLocalizations.of(context)?.translate('s') ?? 'S';
        break;
      case "known":
        borderColor = Colors.green;
        fillColor = Colors.lightGreen[100]!;
        textColor = Colors.green[900]!;
        statusLetter = AppLocalizations.of(context)?.translate('k') ?? 'K';
        break;
      case "new":
      default:
        borderColor = Colors.blue;
        fillColor = Colors.lightBlue[100]!;
        textColor = Colors.blue[900]!;
        statusLetter = AppLocalizations.of(context)?.translate('n') ?? 'N';
        break;
    }

    return Container(
      width: 25,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
                color: fillColor,
              ),
              child: Center(
                child: Text(
                  statusLetter,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}