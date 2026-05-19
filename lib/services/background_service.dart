import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;
import 'storage_service.dart';

class BackgroundServiceManager {
  // Sets up the background service and notification channels
  Future<void> initialize() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_background_channel',
      'Background Tracking',
      description: 'This channel is used for tracking location in background.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_background_channel',
        initialNotificationTitle: 'Location Tracker',
        initialNotificationContent: 'Initializing tracking...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  // Starts the background tracking service
  Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  // Stops the background service
  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  // Stream of location updates from the background task
  Stream<Map<String, dynamic>?> get locationUpdates {
    return FlutterBackgroundService().on('update');
  }
}

// iOS background fetch handler (required by the plugin)
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

// Entry point for the background isolate
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final storage = StorageService();

  Timer? timer;

  service.on('stopService').listen((event) {
    timer?.cancel();
    service.stopSelf();
  });

  timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (position.isMocked) {
        developer.log('WARNING: Mocked location in background',
            name: 'BackgroundService');
      }

      await storage.saveLocation(position.latitude, position.longitude);

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Tracking Location",
          content:
              "Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}",
        );
      }

      service.invoke('update', {
        'lat': position.latitude,
        'lng': position.longitude,
      });
    } catch (e) {
      developer.log('Error in background location', error: e);
    }
  });
}
