import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:location_tracker/main.dart';
import 'package:location_tracker/providers/tracking_provider.dart';
import 'package:location_tracker/providers/tracking_state.dart';

// Creates a mock notifier to avoid triggering real platform channels (Geolocator/Permissions)

class MockTrackingNotifier extends AsyncNotifier<TrackingState>
    implements TrackingNotifier {
  @override
  Future<TrackingState> build() async {
    return TrackingState(
      hasPermission: true,
      permissionMessage: 'Granted',
      statusMessage: 'Ready',
      isTracking: false,
      isLocationServiceEnabled: true,
    );
  }

  @override
  Future<void> checkPermissions() async {}

  @override
  Future<void> refreshSavedLocation() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> toggleTracking() async {}

  @override
  void updateStateWithLocation(double lat, double lng) {}
}

void main() {
  testWidgets('App initializes and renders Home Screen correctly',
      (WidgetTester tester) async {
    // Override the real provider with a mock notifier to avoid platform channel exceptions during testing
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackingProvider.overrideWith(() => MockTrackingNotifier()),
        ],
        child: const MyApp(),
      ),
    );

    // Wait for the AsyncNotifier to resolve its build() method
    await tester.pumpAndSettle();

    // Verify AppBar title is correct
    expect(find.text('Location Tracker'), findsOneWidget);

    // Verify the StatusTiles rendered successfully
    expect(find.text('Location Tracker'), findsOneWidget);

    // Verify the StatusTiles rendered successfully based on the mock state
    expect(find.text('Permission Status'), findsOneWidget);
    expect(find.text('Granted'), findsOneWidget);

    expect(find.text('Tracking Status'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);

    // Verify the primary action button rendered
    expect(find.text('Start Tracking'), findsOneWidget);
  });
}
