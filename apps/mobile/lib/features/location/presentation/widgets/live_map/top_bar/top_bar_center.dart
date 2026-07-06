import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

import 'top_bar_home_icon.dart';
import 'top_bar_search_field.dart';

class TopBarCenter extends StatelessWidget {
  final bool showSearch;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  const TopBarCenter({
    super.key,
    required this.showSearch,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    if (!showSearch) {
      return TopBarHomeIcon(size: context.w(40));
    }

    return Expanded(
      child: TopBarSearchField(
        controller: searchController,
        focusNode: searchFocusNode,
        onChanged: onSearchChanged,
        onClear: onClearSearch,
      ),
    );
  }
}
