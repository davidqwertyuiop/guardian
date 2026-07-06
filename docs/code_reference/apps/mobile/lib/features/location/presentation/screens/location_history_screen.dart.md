# location_history_screen.dart

* **File Path:** `apps/mobile/lib/features/location/presentation/screens/location_history_screen.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';

class LocationHistoryScreen extends StatelessWidget {
  const LocationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Location History', style: TextStyle(fontFamily: 'Outfit')),
      ),
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
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Arrived at 1$index:30 PM • Stayed 20m',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}

```
