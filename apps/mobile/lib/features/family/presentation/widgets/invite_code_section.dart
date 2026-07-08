import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InviteCodeSection extends StatelessWidget {
  const InviteCodeSection({
    super.key,
    required this.code,
    required this.isDark,
    required this.foreground,
  });

  final String? code;
  final bool isDark;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1E1E22) : const Color(0xFFEFEFF2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Or share the code:',
          style: _title(foreground).copyWith(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text('Tap below to copy code', style: _muted(isDark)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: code == null ? null : () => _copy(context, code!),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              code?.split('').join('   ') ?? 'Generating code...',
              style: TextStyle(
                fontFamily: 'Inter',
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  TextStyle _title(Color color) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color,
  );
  TextStyle _muted(bool dark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    color: dark ? Colors.white54 : Colors.black45,
  );
}
