import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String title;
  final double? latitude;
  final double? longitude;
  final IconData icon;

  const LocationCard({
    super.key,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (latitude != null && longitude != null)
                    Text('Lat: ${latitude!.toStringAsFixed(5)}\nLng: ${longitude!.toStringAsFixed(5)}')
                  else
                    const Text('No location data available'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}