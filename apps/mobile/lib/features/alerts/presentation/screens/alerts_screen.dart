import 'package:flutter/material.dart';
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Security Alerts', style: TextStyle(fontFamily: 'Outfit', ))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAlertCard(
            title: 'Dad started a journey',
            time: '10m ago',
            icon: Icons.directions_run,
            color: Colors.blue,
          ),
          _buildAlertCard(
            title: 'Mom arrived at Home',
            time: '35m ago',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
          _buildAlertCard(
            title: 'SOS Alert triggered by Sister',
            time: '1h ago',
            icon: Icons.warning_amber_rounded,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        subtitle: Text(time, style: TextStyle(fontFamily: 'Inter', fontSize: 12)),
      ),
    );
  }
}
