import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double bellSize = context.w(40);
    final double centerIconSize = context.w(40);
    final double sosHeight = context.w(40);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: showBackButton ? onBackPressed : null,
            child: Container(
              width: bellSize,
              height: bellSize,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: showBackButton
                    ? Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: context.w(18),
                        color: isDark ? Colors.white : const Color(0xFF1C1C24),
                      )
                    : Image.asset(
                        AppAssets.phBell,
                        width: context.w(20),
                        height: context.w(20),
                        color: isDark
                            ? const Color(0xFFD7D7DE)
                            : const Color(0xFF1C1C24),
                        errorBuilder: (_, _, _) => Icon(
                          Icons.notifications_none_rounded,
                          size: context.w(20),
                          color: isDark
                              ? const Color(0xFFD7D7DE)
                              : const Color(0xFF1C1C24),
                        ),
                      ),
              ),
            ),
          ),

          // Centre: Expandable search bar OR Guardian Home Icon / Address Pill
          if (showSearch)
            Expanded(
              child: Container(
                height: context.w(40),
                margin: EdgeInsets.symmetric(horizontal: context.w(10)),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: context.w(12)),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: isDark ? Colors.white54 : Colors.black54,
                      size: context.w(18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        onChanged: onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search places...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: context.sp(13),
                            fontFamily: 'Inter',
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: context.sp(14),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    if (searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: onClearSearch,
                        child: Icon(
                          Icons.clear_rounded,
                          color: isDark ? Colors.white54 : Colors.black54,
                          size: context.w(16),
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            // In compact mode, show the center home icon
            Image.asset(
              AppAssets.appCenterHomeIcon,
              width: centerIconSize,
              height: centerIconSize,
              errorBuilder: (_, _, _) => Container(
                width: centerIconSize,
                height: centerIconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF28243D)
                      : const Color(0xFFE5DEFF),
                ),
                child: Icon(
                  Icons.map_rounded,
                  color: isDark
                      ? const Color(0xFF8F76FF)
                      : const Color(0xFF7C60FF),
                  size: context.w(22),
                ),
              ),
            ),

          // SOS trigger
          GestureDetector(
            onTap: onSosTap,
            child: Container(
              height: sosHeight,
              padding: EdgeInsets.only(
                left: context.w(16),
                right: context.w(6),
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C34)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SOS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF3380),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: sosHeight - 12,
                      height: sosHeight - 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3380),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                          size: context.w(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
