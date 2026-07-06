part of '../heading_out_bottom_sheet.dart';

class HeadingOutIosPicker extends StatelessWidget {
  final String currentValue;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool isDark;

  const HeadingOutIosPicker({super.key, 
    required this.currentValue,
    required this.options,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      color: isDark ? const Color(0xFF1E1E24) : Colors.white,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done', style: TextStyle(fontFamily: 'Inter')),
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
                itemExtent: 40,
                onSelectedItemChanged: (index) => onChanged(options[index]),
                children: options.map((option) {
                  return Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
