import 'package:amplitude_flutter/amplitude.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/entities/user.dart';
import 'package:linguome/services/user_service.dart';

class AmplitudeManager {
  static final AmplitudeManager _instance = AmplitudeManager._internal();
  final Amplitude _analytics;

  factory AmplitudeManager() {
    return _instance;
  }

  AmplitudeManager._internal() : _analytics = Amplitude.getInstance(instanceName: AppConfig.instanceName) {
    _analytics.init(AppConfig.amplitudeApiKey);
  }

  Amplitude get analytics => _analytics;

  Future<void> logProfileEvent(String eventName, {Map<String, dynamic>? eventProperties}) async {
    User? user = await UserService.getCurrentUser();
    if (user != null) {
      Map<String, dynamic> properties = {
        'email': user.email,
        'eventName': eventName,
      };

      if (eventProperties != null) {
        properties.addAll(eventProperties);
      }
      _analytics.logEvent('ProfileEvent', eventProperties: properties);
    } else {
      print('User not found');
    }
  }
}