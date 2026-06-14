import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationHistoryScreen extends StatelessWidget {
  const LocationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text('Location History', style: GoogleFonts.outfit())),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8E5FF),
                child: Icon(Icons.location_on, color: Color(0xFF7C60FF)),
              ),
              title: Text(
                'Location Stop ${index + 1}',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Arrived at 1$index:30 PM • Stayed 20m',
                style: GoogleFonts.inter(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
