import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Asks for both foreground and background location access
  Future<PermissionStatus> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    
    if (status.isGranted) {
      status = await Permission.locationAlways.request();
    }
    
    return status;
  }

  // Asks for notification access (mostly for Android 13+)
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Checks if we already have location access
  Future<PermissionStatus> checkLocationPermissionStatus() async {
    final always = await Permission.locationAlways.status;
    if (always.isGranted) return always;
    
    return await Permission.locationWhenInUse.status;
  }

  // Checks if the device's GPS is actually turned on
  Future<bool> isLocationServiceEnabled() async {
    return await Permission.location.serviceStatus.isEnabled;
  }
}