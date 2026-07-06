import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

import 'top_bar/top_bar_center.dart';
import 'top_bar/top_bar_leading_button.dart';
import 'top_bar/top_bar_sos_button.dart';

class LiveMapTopBar extends StatelessWidget {
  final bool showSearch;
  final VoidCallback onSosTap;
  final double latitude;
  final double longitude;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final FocusNode searchFocusNode;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool isSosActive;

  const LiveMapTopBar({
    super.key,
    required this.showSearch,
    required this.onSosTap,
    required this.latitude,
    required this.longitude,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.searchFocusNode,
    this.showBackButton = false,
    this.onBackPressed,
    this.isSosActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = context.w(40);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TopBarLeadingButton(
            size: buttonSize,
            showBackButton: showBackButton,
            onBackPressed: onBackPressed,
          ),
          TopBarCenter(
            showSearch: showSearch,
            searchController: searchController,
            searchFocusNode: searchFocusNode,
            onSearchChanged: onSearchChanged,
            onClearSearch: onClearSearch,
          ),
          TopBarSosButton(
            height: buttonSize,
            onTap: onSosTap,
            isActive: isSosActive,
          ),
        ],
      ),
    );
  }
}
