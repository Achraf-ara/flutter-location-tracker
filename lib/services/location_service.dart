import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class LocationService {
  // Grabs the user's current GPS location
  Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      if (position.isMocked) {
        developer.log('WARNING: Mocked/spoofed location detected!', name: 'LocationService');
      }
      
      return position;
    } catch (e) {
      developer.log('Error getting location', error: e, name: 'LocationService');
      return null;
    }
  }
}