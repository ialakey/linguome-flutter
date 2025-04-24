import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:linguome/entities/user.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/screens/games/game_description_word_screen.dart';
import 'package:linguome/screens/games/game_sentence.dart';
import 'package:linguome/screens/games/start_game_screen.dart';
import 'package:linguome/widgets/game_card.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamesScreen extends StatefulWidget {
  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  late Timer _timer;
  int? _timeSpentInMinutes;
  int _colorIndex = 0;
  List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAndStartTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadUserAndStartTimer() async {
    try {
      final user = await getUser();
      setState(() {
        _timeSpentInMinutes = (user.timeSpentInGame ?? 0) ~/ 60;
      });

      _timer = Timer.periodic(Duration(minutes: 1), (timer) {
        setState(() {
          _timeSpentInMinutes = (_timeSpentInMinutes ?? 0) + 1;

          if (_timeSpentInMinutes! % 60 == 0) {
            _colorIndex = (_colorIndex + 1) % _colors.length;
          }

          updateUserTimeSpent(user, _timeSpentInMinutes ?? 0);
        });
      });
    } catch (error) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: AppLocalizations.of(context)!.translate('error'),
        text: AppLocalizations.of(context)!.translate('errorFetchData'),
      );
    }
  }

  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('user');
    if (userDataJson != null) {
      return User.fromJson(json.decode(userDataJson));
    } else {
      throw Exception('User data not found');
    }
  }

  void updateUserTimeSpent(User user, int timeSpentInMinutes) async {
    final prefs = await SharedPreferences.getInstance();
    int timeSpentInSeconds = timeSpentInMinutes * 60;
    user.timeSpentInGame = timeSpentInSeconds;
    await prefs.setString('user', json.encode(user.toJson()));
  }

  String _formatDuration(int? durationInMinutes) {
    if (durationInMinutes == null) return '0 days 0 hours 0 minutes';

    int days = durationInMinutes ~/ (24 * 60);
    int hours = (durationInMinutes ~/ 60) % 24;
    int minutes = durationInMinutes % 60;

    return '$days days $hours hours $minutes minutes';
  }

  @override
  Widget build(BuildContext context) {
    int timeSpentInMinutes = _timeSpentInMinutes ?? 0;
    int woodImageIndex = (timeSpentInMinutes ~/ 60) % 8 + 1;
    String formattedTimeSpentInGame = _formatDuration(timeSpentInMinutes);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.translate('games')),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 10),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 250,
                child: Image.asset(
                  'assets/woods/wood_$woodImageIndex.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 10),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        value: timeSpentInMinutes % 60 / 60,
                        strokeWidth: 20,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(_colors[_colorIndex]),
                      ),
                    ),
                    Text(
                      '${timeSpentInMinutes ~/ 60}',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 10),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('timeSpent'),
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      formattedTimeSpentInGame,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.translate('games'),
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                GameCard(
                  title: AppLocalizations.of(context)!.translate('wordByDescription'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StartGameScreen(
                          nextScreen: GameDescriptionWordScreen(),
                          howToPlayText: AppLocalizations.of(context)!.translate('howToPlay'),
                          description: AppLocalizations.of(context)!.translate('wordByDescription'),
                        ),
                      ),
                    );
                  },
                ),
                GameCard(
                  title: AppLocalizations.of(context)!.translate('insertTheWordIntoTheSentence'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StartGameScreen(
                          nextScreen: EnglishLearningGame(),
                          howToPlayText: AppLocalizations.of(context)!.translate('howToPlay'),
                          description: AppLocalizations.of(context)!.translate('insertTheWordIntoTheSentence'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}