import 'package:flutter/material.dart';
import 'package:flutter_arc_speed_dial/flutter_speed_dial_menu_button.dart';
import 'package:flutter_arc_speed_dial/main_menu_floating_action_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linguome/config/app_colors.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/entities/full_page.dart';
import 'package:linguome/helper/amplitude_manager.dart';
import 'package:linguome/screens/add_text_screen.dart';
import 'package:linguome/screens/page_screen.dart';
import 'package:linguome/services/handler_processing_service.dart';

class CustomFloatingActionButton extends StatefulWidget {
  const CustomFloatingActionButton({super.key});

  @override
  _CustomFloatingActionButtonState createState() =>
      _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState
    extends State<CustomFloatingActionButton> {
  bool _isShowDial = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _getFloatingActionButton(),
      ],
    );
  }

  Widget _getFloatingActionButton() {
    HandlerProcessingService imageProcessingService = HandlerProcessingService();

    return SpeedDialMenuButton(
      isShowSpeedDial: _isShowDial,
      updateSpeedDialStatus: (isShow) {
        setState(() {
          _isShowDial = isShow;
        });
      },
      isMainFABMini: false,
      mainMenuFloatingActionButton: MainMenuFloatingActionButton(
        mini: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Image.asset('${AppConfig.assetsIcons}plus.png', width: 24, height: 24),
        onPressed: () {},
        closeMenuChild: Image.asset('${AppConfig.assetsIcons}x.png', width: 24, height: 24),
        closeMenuForegroundColor: AppColors.closeMenuForegroundColor,
        closeMenuBackgroundColor: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      floatingActionButtonWidgetChildren: <FloatingActionButton>[
        FloatingActionButton(
          heroTag: 'camera_fab',
          mini: true,
          child: Image.asset('${AppConfig.assetsIcons}camera.png', width: 24, height: 24),
          onPressed: () async {
            setState(() {
              _isShowDial = false;
            });
            FullPage? createdPage = await imageProcessingService.takePictureOrGallery(ImageSource.camera, context);

            if (createdPage != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    PageScreen(
                      title: createdPage.pageLinguome.title,
                      vocabList: createdPage.items,
                    )),
              );
              AmplitudeManager()
                  .logProfileEvent(
                  'CustomFloatingActionButton',
                  eventProperties: {
                    'button_clicked': 'camera',
                  });
            }
          },
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        FloatingActionButton(
          heroTag: 'galery_fab',
          mini: true,
          child: Image.asset('${AppConfig.assetsIcons}picture.png', width: 24, height: 24),
          onPressed: () async {
            AmplitudeManager()
                .logProfileEvent(
                'CustomFloatingActionButton',
                eventProperties: {
                  'button_clicked': 'galery',
                });
            _isShowDial = false;

            FullPage? createdPage = await imageProcessingService.takePictureOrGallery(ImageSource.gallery, context);

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
          },
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        FloatingActionButton(
          heroTag: 'text_fab',
          mini: true,
          child: Image.asset('${AppConfig.assetsIcons}text.png', width: 24, height: 24),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTextScreen()),
            );
            AmplitudeManager()
                .logProfileEvent(
                'CustomFloatingActionButton',
                eventProperties: {
                  'button_clicked': 'text',
                });
          },
          backgroundColor:Theme.of(context).colorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ],
      isSpeedDialFABsMini: true,
      paddingBtwSpeedDialButton: 30.0,
    );
  }
}