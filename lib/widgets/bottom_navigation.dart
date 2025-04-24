import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/entities/full_page.dart';
import 'package:linguome/helper/amplitude_manager.dart';
import 'package:linguome/localizations/app_localizations.dart';
import 'package:linguome/screens/games/games_screen.dart';
import 'package:linguome/screens/home_screen.dart';
import 'package:linguome/screens/page_screen.dart';
import 'package:linguome/screens/profile_screen.dart';
import 'package:linguome/screens/search_screen.dart';
import 'package:linguome/services/handler_processing_service.dart';
import 'package:linguome/widgets/floating_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigation extends StatefulWidget {
  final int initialIndex;

  BottomNavigation({required this.initialIndex});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  bool _introStarted = false;

  static final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    Container(),
    GamesScreen(),
    ProfileScreen(),
  ];

  static const List<String> _menuLabels = [
    'home',
    'search',
    'photo',
    'games',
    'profile',
  ];

  @override
  void initState() {
    super.initState();
    _checkIntroStatus();
    _selectedIndex = widget.initialIndex;
  }

  Future<void> _checkIntroStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool introShown = prefs.getBool('introShown') ?? false;
    setState(() {
      _introStarted = !introShown;
    });
  }

  Future<void> _onItemTapped(int index) async {
    if (index == 2) {
      FullPage? createdPage = await HandlerProcessingService().takePictureOrGallery(ImageSource.camera, context);

      if (createdPage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              PageScreen(
                title: createdPage.pageLinguome.title,
                vocabList: createdPage.items,
              )),
        );
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });

      AmplitudeManager()
          .analytics.logEvent(
          'Bottom Navigation Tapped',
          eventProperties: {'label': _menuLabels[index]}
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: List.generate(
          _menuLabels.length,
              (index) => BottomNavigationBarItem(
            icon: _getIcon(_menuLabels[index], context),
            label: AppLocalizations.of(context)!.translate(_menuLabels[index]),
          ),
        ),
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.selectedItemColor,
        unselectedItemColor: AppColors.unselectedItemColor,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.background,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      floatingActionButton: _shouldShowFAB(_selectedIndex)
          ? CustomFloatingActionButton() : null,
    );
  }

  Widget _getIcon(String label, BuildContext context) {
    switch (label) {
      case 'home':
        return _introStarted ? IntroStepBuilder(
            order: 1,
            text: AppLocalizations.of(context)!.translate('homeDescription'),
            padding: const EdgeInsets.only(
              bottom: 20,
              left: 16,
              right: 16,
              top: 8,
            ),
            onWidgetLoad: () {
              Intro.of(context).start();
            },
            builder: (context, key) {
              AmplitudeManager()
                  .logProfileEvent(
                  'BottomNavigation manual',
                  eventProperties: {
                    'button_clicked': 'home',
                  });
              return Image.asset('${AppConfig.assetsIcons}home.png', width: 24, height: 24, key: key,);
            }
        ) : Image.asset('${AppConfig.assetsIcons}home.png', width: 24, height: 24);
      case 'search':
        return _introStarted ? IntroStepBuilder(
            order: 2,
            text: AppLocalizations.of(context)!.translate('searchDescription'),
            padding: const EdgeInsets.only(
              bottom: 20,
              left: 16,
              right: 16,
              top: 8,
            ),
            builder: (context, key) {
              AmplitudeManager()
                  .logProfileEvent(
                  'BottomNavigation manual',
                  eventProperties: {
                    'button_clicked': 'search',
                  });
              return Image.asset('${AppConfig.assetsIcons}search.png', width: 24, height: 24, key: key,);
            }
        ) : Image.asset('${AppConfig.assetsIcons}search.png', width: 24, height: 24);
      case 'photo':
        return _introStarted ? IntroStepBuilder(
            order: 3,
            text: AppLocalizations.of(context)!.translate('photoDescription'),
            padding: const EdgeInsets.only(
              bottom: 20,
              left: 16,
              right: 16,
              top: 8,
            ),
            builder: (context, key) {
              AmplitudeManager()
                  .logProfileEvent(
                  'BottomNavigation manual',
                  eventProperties: {
                    'button_clicked': 'photo',
                  });
              return Image.asset('${AppConfig.assetsIcons}camera.png', width: 24, height: 24, key: key,);
            }
        ) : Image.asset('${AppConfig.assetsIcons}camera.png', width: 24, height: 24);
      case 'games':
        return _introStarted ? IntroStepBuilder(
            order: 4,
            text: AppLocalizations.of(context)!.translate('gamesDescription'),
            padding: const EdgeInsets.only(
              bottom: 20,
              left: 16,
              right: 16,
              top: 8,
            ),
            builder: (context, key) {
              AmplitudeManager()
                  .logProfileEvent(
                  'BottomNavigation manual',
                  eventProperties: {
                    'button_clicked': 'games',
                  });
              return Image.asset('${AppConfig.assetsIcons}gamepad.png', width: 24, height: 24, key: key,);
            }
        ) : Image.asset('${AppConfig.assetsIcons}gamepad.png', width: 24, height: 24);
      case 'profile':
        return _introStarted ? IntroStepBuilder(
            order: 5,
            padding: const EdgeInsets.only(
              bottom: 20,
              left: 16,
              right: 16,
              top: 8,
            ),
            overlayBuilder: (params) {
              return Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.helpColor,
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('profileDescription'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                      ),
                      child: Row(
                        children: [
                          IntroButton(
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('introShown', true);
                              setState(() {
                                _introStarted = false;
                              });
                              params.onFinish();
                              AmplitudeManager()
                                  .logProfileEvent(
                                  'BottomNavigation manual',
                                  eventProperties: {
                                    'button_clicked': 'manual completed',
                                  });
                            },
                            text: AppLocalizations.of(context)!.translate('finish'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            builder: (context, key) =>
                Image.asset('${AppConfig.assetsIcons}user.png', width: 24, height: 24, key: key,)
        ) : Image.asset('${AppConfig.assetsIcons}user.png', width: 24, height: 24);
      default:
        return Image.asset('${AppConfig.assetsIcons}user.png', width: 24, height: 24);
    }
  }

  bool _shouldShowFAB(int index) {
    return index == 0;
  }
}