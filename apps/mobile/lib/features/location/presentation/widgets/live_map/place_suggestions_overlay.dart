import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

import '../../../domain/models/live_map_models.dart';

class PlaceSuggestionsOverlay extends StatelessWidget {
  final bool isVisible;
  final List<LivePlace> suggestions;
  final ValueChanged<LivePlace> onSuggestionTap;

  const PlaceSuggestionsOverlay({
    super.key,
    required this.isVisible,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.paddingOf(context).top + 66,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          itemCount: suggestions.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: const Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                suggestion.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              subtitle: suggestion.address.isNotEmpty
                  ? Text(
                      suggestion.address,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    )
                  : null,
              onTap: () => onSuggestionTap(suggestion),
            );
          },
        ),
      ),
    );
  }
}
