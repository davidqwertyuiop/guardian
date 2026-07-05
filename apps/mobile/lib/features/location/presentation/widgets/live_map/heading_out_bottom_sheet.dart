import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardian/export.dart';
import 'member_avatar_row.dart';
import 'you_are_live_bottom_sheet.dart';

class HeadingOutBottomSheet extends StatefulWidget {
  final String initialCircleId;
  final String initialCircleName;
  final List<dynamic> initialMembers;

  const HeadingOutBottomSheet({
    super.key,
    required this.initialCircleId,
    required this.initialCircleName,
    required this.initialMembers,
  });

  @override
  State<HeadingOutBottomSheet> createState() => _HeadingOutBottomSheetState();
}

class _HeadingOutBottomSheetState extends State<HeadingOutBottomSheet> {
  String _selectedDestination = 'Home';
  String _selectedDuration = '30 Mins';
  final TextEditingController _customDestController = TextEditingController();
  final TextEditingController _customDurController = TextEditingController();

  List<Map<String, dynamic>> _circles = [];
  String _selectedCircleId = '';
  bool _isLoadingCircles = false;

  final List<String> _destinationOptions = ['Home', 'Work', 'School', 'Custom'];
  final List<String> _durationOptions = [
    '30 Mins',
    '1 Hr',
    '2 Hrs',
    'Until I arrive',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCircleId = widget.initialCircleId;
    if (widget.initialCircleId.isNotEmpty) {
      _circles = [
        {
          'id': widget.initialCircleId,
          'name': widget.initialCircleName,
          'members': widget.initialMembers,
        },
      ];
    }
    _fetchCircles();
  }

  Future<void> _fetchCircles() async {
    setState(() {
      _isLoadingCircles = true;
    });
    try {
      final circlesData = await ApiService.getCircles();
      List<Map<String, dynamic>> loadedCircles = [];
      for (var c in circlesData) {
        final circleId = c['id'] as String;
        List<dynamic> members = [];
        try {
          members = await ApiService.getCircleMembers(circleId);
        } catch (_) {}
        loadedCircles.add({
          'id': circleId,
          'name': c['name'] ?? '',
          'members': members,
        });
      }
      if (mounted) {
        setState(() {
          _circles = loadedCircles;
          if (_circles.isNotEmpty && _selectedCircleId.isEmpty) {
            _selectedCircleId = _circles.first['id'];
          }
          _isLoadingCircles = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCircles = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _customDestController.dispose();
    _customDurController.dispose();
    super.dispose();
  }

  void _showIosPicker({
    required BuildContext context,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: CupertinoPicker(
                  backgroundColor: Colors.transparent,
                  scrollController: FixedExtentScrollController(
                    initialItem: options.indexOf(currentValue),
                  ),
                  itemExtent: 40.0,
                  onSelectedItemChanged: (int index) {
                    onChanged(options[index]);
                  },
                  children: List<Widget>.generate(options.length, (int index) {
                    return Center(
                      child: Text(
                        options[index],
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgBoxColor = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final dropdownBorderColor = isDark
        ? Colors.white24
        : const Color(0xFFE5E5EA);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgBoxColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white10
                            : const Color(0xFFF2F2F7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 20, color: textColor),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "I'm heading out",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Broadcast",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the close button
                ],
              ),
              const SizedBox(height: 32),

              // Destination
              Text(
                "Where are you headed?",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                value: _selectedDestination,
                options: _destinationOptions,
                borderColor: dropdownBorderColor,
                textColor: textColor,
                isDark: isDark,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDestination = val);
                },
              ),
              if (_selectedDestination == 'Custom') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customDestController,
                  decoration: InputDecoration(
                    hintText: "Enter destination",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black38,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: dropdownBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Duration
              Text(
                "How long should we track you?",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                value: _selectedDuration,
                options: _durationOptions,
                borderColor: dropdownBorderColor,
                textColor: textColor,
                isDark: isDark,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDuration = val);
                },
              ),
              if (_selectedDuration == 'Custom') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customDurController,
                  decoration: InputDecoration(
                    hintText: "e.g., 30 mins, 4 hours",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black38,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: dropdownBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              Text(
                "Your circle will be notified when you start and when you arrive.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Circle Selector List
              if (_circles.isEmpty && _isLoadingCircles)
                const Center(child: CircularProgressIndicator())
              else if (_circles.isEmpty)
                const Text("No circles found.")
              else
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _circles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final c = _circles[index];
                      final isSelected = c['id'] == _selectedCircleId;
                      return _buildCircleCard(
                        name: c['name'],
                        members: c['members'] ?? [],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCircleId = c['id'];
                          });
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 32),

              // Bottom Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final destination = _selectedDestination == 'Custom'
                        ? _customDestController.text
                        : _selectedDestination;

                    Navigator.pop(context); // close heading out sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => YouAreLiveBottomSheet(
                        destination: destination.isEmpty
                            ? "unknown location"
                            : destination,
                      ),
                    );
                  },
                  child: const Text(
                    "Start broadcasting",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> options,
    required Color borderColor,
    required Color textColor,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    if (Platform.isIOS) {
      return GestureDetector(
        onTap: () {
          _showIosPicker(
            context: context,
            currentValue: value,
            options: options,
            isDark: isDark,
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ],
          ),
        ),
      );
    }

    // Android / Web standard dropdown
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
          dropdownColor: isDark ? const Color(0xFF2A2A30) : Colors.white,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          items: options.map((opt) {
            return DropdownMenuItem<String>(value: opt, child: Text(opt));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCircleCard({
    required String name,
    required List<dynamic> members,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final borderColor = isSelected
        ? const Color(0xFFBB86FC)
        : Colors.transparent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? borderColor
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name.isNotEmpty ? name : "My Circle",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                      height: 1.2,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFFBB86FC),
                    size: 20,
                  ),
              ],
            ),
            MemberAvatarRow(members: members),
          ],
        ),
      ),
    );
  }
}
