part of '../sos_bottom_sheet.dart';

class SosButtonLoader extends StatelessWidget {
  const SosButtonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}

class SosButtonText extends StatelessWidget {
  final String text;

  const SosButtonText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
