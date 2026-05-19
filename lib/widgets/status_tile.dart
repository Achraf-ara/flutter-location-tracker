import 'package:flutter/material.dart';

class StatusTile extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final Color statusColor;

  const StatusTile({
    super.key,
    required this.title,
    required this.status,
    required this.icon,
    this.statusColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 32),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(status, style: TextStyle(color: statusColor)),
    );
  }
}