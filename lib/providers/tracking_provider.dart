import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tracking_state.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../services/background_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:permission_handler/permission_handler.dart';

final locationServiceProvider = Provider((ref) => LocationService());
final permissionServiceProvider = Provider((ref) => PermissionService());
final storageServiceProvider = Provider((ref) => StorageService());
final backgroundServiceProvider = Provider((ref) => BackgroundServiceManager());

final trackingProvider =
    AsyncNotifierProvider<TrackingNotifier, TrackingState>(() {
  return TrackingNotifier();
});

class TrackingNotifier extends AsyncNotifier<TrackingState> {
  // Initial setup when the provider first loads
  @override
  Future<TrackingState> build() async {
    final storage = ref.read(storageServiceProvider);

    final lastLoc = await storage.getLastLocation();

    final isServiceRunning = await FlutterBackgroundService().isRunning();

    _listenToBackgroundUpdates();

    final observer = _LifecycleObserver(onResumed: checkPermissions);
    WidgetsBinding.instance.addObserver(observer);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(observer);
    });

    final permission = ref.read(permissionServiceProvider);

    final isEnabled = await permission.isLocationServiceEnabled();
    final status = await permission.checkLocationPermissionStatus();

    String message = 'Not Requested';
    bool hasPerm = false;

    if (status.isGranted) {
      message = 'Granted';
      hasPerm = true;
    } else if (status.isDenied) {
      message = 'Denied';
    } else if (status.isPermanentlyDenied) {
      message = 'Permanently Denied - Open Settings';
    }

    return TrackingState(
      savedLat: lastLoc?['lat'],
      savedLng: lastLoc?['lng'],
      isTracking: isServiceRunning,
      isLocationServiceEnabled: isEnabled,
      hasPermission: hasPerm,
      permissionMessage: message,
      statusMessage: !isEnabled
          ? 'Location Service Disabled'
          : (hasPerm
              ? (isServiceRunning ? 'Tracking active' : 'Ready')
              : 'Permission Required'),
    );
  }

  // Hooks into the background service stream to keep UI in sync
  void _listenToBackgroundUpdates() {
    final bg = ref.read(backgroundServiceProvider);
    final subscription = bg.locationUpdates.listen((event) {
      if (event != null) {
        final lat = event['lat'] as double;
        final lng = event['lng'] as double;
        updateStateWithLocation(lat, lng);
      }
    });

    ref.onDispose(() {
      subscription.cancel();
    });
  }

  // Updates the state with new coordinates
  void updateStateWithLocation(double lat, double lng) {
    if (state.value == null) return;

    state = AsyncData(state.value!.copyWith(
      currentLat: lat,
      currentLng: lng,
      savedLat: lat,
      savedLng: lng,
      statusMessage: 'Tracking active',
    ));
  }

  // Triggers the permission prompts
  Future<void> requestPermissions() async {
    final permission = ref.read(permissionServiceProvider);

    await permission.requestLocationPermission();

    if (state.value != null) {
      await checkPermissions();
    }
  }

  // Starts or stops the actual tracking based on current state
  Future<void> toggleTracking() async {
    if (state.value == null) return;

    var currentState = state.value!;
    final bg = ref.read(backgroundServiceProvider);

    if (currentState.isTracking) {
      await bg.stopService();
      state = AsyncData(currentState.copyWith(
        isTracking: false,
        statusMessage: 'Tracking stopped',
      ));
      return;
    }

    await checkPermissions();
    if (state.value == null) return;

    currentState = state.value!;

    if (!currentState.isLocationServiceEnabled) {
      state = AsyncData(currentState.copyWith(
        statusMessage: 'Please enable Location Services',
      ));
      return;
    }

    if (!currentState.hasPermission) {
      await requestPermissions();
      if (state.value == null || !state.value!.hasPermission) return;
      currentState = state.value!;
    }

    final permission = ref.read(permissionServiceProvider);
    final hasNotificationPermission =
        await permission.requestNotificationPermission();

    currentState = state.value!;

    await bg.startService();

    state = AsyncData(currentState.copyWith(
      isTracking: true,
      statusMessage: hasNotificationPermission
          ? 'Tracking started'
          : 'Tracking started, but notification permission denied',
    ));

    final locService = ref.read(locationServiceProvider);
    final storage = ref.read(storageServiceProvider);
    final pos = await locService.getCurrentLocation();

    if (pos != null) {
      await storage.saveLocation(pos.latitude, pos.longitude);
      updateStateWithLocation(pos.latitude, pos.longitude);
    }
  }

  // Loads the last saved location from local storage and updates the UI
  Future<void> refreshSavedLocation() async {
    if (state.value == null) return;
    final storage = ref.read(storageServiceProvider);
    final lastLoc = await storage.getLastLocation();

    await checkPermissions();

    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(
        savedLat: lastLoc?['lat'],
        savedLng: lastLoc?['lng'],
      ));
    }
  }

  // Double checks if we still have permission (e.g. after coming back from settings)
  Future<void> checkPermissions() async {
    if (state.value == null) return;
    final permission = ref.read(permissionServiceProvider);

    final isEnabled = await permission.isLocationServiceEnabled();
    final status = await permission.checkLocationPermissionStatus();

    String message = 'Not Requested';
    bool hasPerm = false;

    if (status.isGranted) {
      message = 'Granted';
      hasPerm = true;
    } else if (status.isDenied) {
      message = 'Denied';
    } else if (status.isPermanentlyDenied) {
      message = 'Permanently Denied - Open Settings';
    }

    state = AsyncData(state.value!.copyWith(
      isLocationServiceEnabled: isEnabled,
      hasPermission: hasPerm,
      permissionMessage: message,
      statusMessage: !isEnabled
          ? 'Location Service Disabled'
          : (hasPerm
              ? (state.value!.isTracking ? 'Tracking active' : 'Ready')
              : 'Permission Required'),
    ));
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  // Fires when the app comes back to the foreground
  final VoidCallback onResumed;

  _LifecycleObserver({required this.onResumed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
