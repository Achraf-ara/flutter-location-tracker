import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _latKey = 'last_lat';
  static const String _lngKey = 'last_lng';

  // Saves the coordinates locally so they survive app restarts
  Future<void> saveLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lngKey, lng);
  }

  // Loads the last known coordinates if we have them
  Future<Map<String, double>?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);

    if (lat != null && lng != null) {
      return {'lat': lat, 'lng': lng};
    }
    return null;
  }
}
