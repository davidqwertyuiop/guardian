part of '../sos_bottom_sheet.dart';

class SosVisibilityList extends StatelessWidget {
  final bool isDark;

  const SosVisibilityList({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white70 : Colors.black54;
    return Column(
      children: [
        Text(
          'Your circle can see:',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: color),
        ),
        const SizedBox(height: 8),
        _item('Your live location', color),
        _item('Your battery level', color),
        _item('This SOS alert', color),
      ],
    );
  }

  Widget _item(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '✓ $text',
        style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: color),
      ),
    );
  }
}
