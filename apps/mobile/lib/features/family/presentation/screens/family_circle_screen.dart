import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';

class FamilyCircleScreen extends StatelessWidget {
  const FamilyCircleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Circle', style: TextStyle(fontFamily: 'Outfit')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family Members',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildMemberTile('Mom', 'At Home', isOnline: true),
                  _buildMemberTile('Dad', 'At Work', isOnline: true),
                  _buildMemberTile('Sister', 'Offline', isOnline: false),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                label: Text(
                  'Invite Member',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(
    String name,
    String status, {
    required bool isOnline,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFECEBFF),
        child: Text(
          name[0],
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
      ),
      subtitle: Text(status),
      trailing: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: isOnline ? Colors.green : Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
