import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tracking_provider.dart';
import '../widgets/location_card.dart';
import '../widgets/status_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingStateAsync = ref.watch(trackingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(trackingProvider.notifier).refreshSavedLocation();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: trackingStateAsync.when(
          data: (state) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                StatusTile(
                  title: 'Permission Status',
                  status: state.permissionMessage,
                  icon: Icons.security,
                  statusColor: state.hasPermission ? Colors.green : Colors.red,
                ),
                const Divider(),
                StatusTile(
                  title: 'Tracking Status',
                  status: state.statusMessage,
                  icon: state.isTracking
                      ? Icons.directions_run
                      : Icons.stop_circle,
                  statusColor: state.isTracking ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 16),
                LocationCard(
                  title: 'Current Location',
                  latitude: state.currentLat,
                  longitude: state.currentLng,
                  icon: Icons.my_location,
                ),
                LocationCard(
                  title: 'Last Saved Location',
                  latitude: state.savedLat,
                  longitude: state.savedLng,
                  icon: Icons.save,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(trackingProvider.notifier).toggleTracking(),
                    icon:
                        Icon(state.isTracking ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      state.isTracking ? 'Stop Tracking' : 'Start Tracking',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: state.isTracking
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
