import 'package:flutter/material.dart';

class SosBroadcastEmpty extends StatelessWidget {
  const SosBroadcastEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        'No SOS broadcasts in this circle.',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Color(0xFF888899),
        ),
      ),
    );
  }
}
