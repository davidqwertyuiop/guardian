import 'package:flutter/material.dart';

import '../../../../domain/models/live_map_models.dart';

class DirectionsPlaceText extends StatelessWidget {
  final SelectedLivePlace place;
  final bool isDark;

  const DirectionsPlaceText({
    super.key,
    required this.place,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          place.name,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          place.address,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
