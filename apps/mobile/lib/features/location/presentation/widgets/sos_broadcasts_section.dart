import 'package:flutter/material.dart';

import 'sos_broadcasts/sos_broadcast_card.dart';
import 'sos_broadcasts/sos_broadcast_entry.dart';

class SosBroadcastsSection extends StatelessWidget {
  final List<dynamic> broadcasts;
  final VoidCallback? onSeeAllTap;

  const SosBroadcastsSection({
    super.key,
    required this.broadcasts,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final entries = broadcasts.map(SosBroadcastEntry.fromJson).toList();

    return SosBroadcastCard(entries: entries, onSeeAllTap: onSeeAllTap);
  }
}
