# member_location_screen.dart

* **File Path:** `apps/mobile/lib/features/location/presentation/screens/member_location_screen.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';

class MemberLocationScreen extends StatelessWidget {
  final String memberName;
  const MemberLocationScreen({super.key, required this.memberName});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('$memberName\'s Location')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF7C60FF),
              child: Text(
                memberName[0],
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              memberName,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last active: 2 minutes ago',
              style: TextStyle(fontFamily: 'Inter', color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

```
