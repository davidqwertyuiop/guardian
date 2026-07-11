import 'package:flutter/material.dart';

Future<void> showPauseLocationDialog(
  BuildContext context, {
  required void Function(DateTime?) onPause,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => PauseLocationDialog(onPause: onPause),
  );
}

class PauseLocationDialog extends StatefulWidget {
  const PauseLocationDialog({super.key, required this.onPause});
  final void Function(DateTime?) onPause;

  @override
  State<PauseLocationDialog> createState() => _PauseLocationDialogState();
}

class _PauseLocationDialogState extends State<PauseLocationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Close button (X) in top right
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular pink icon in top center
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sensors_rounded,
                      color: Color(0xFFFF2D7A),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pause your location',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your circle won't see your location while sharing\nis paused. They'll see \"Location paused.\"",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Dropdown selector button
                Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: Colors.white,
                  ),
                  child: PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    onSelected: (value) async {
                      if (value == '30m') {
                        Navigator.pop(context);
                        widget.onPause(DateTime.now().add(const Duration(minutes: 30)));
                      } else if (value == '1h') {
                        Navigator.pop(context);
                        widget.onPause(DateTime.now().add(const Duration(hours: 1)));
                      } else if (value == 'custom') {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null && context.mounted) {
                          Navigator.pop(context);
                          final now = DateTime.now();
                          var selected = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                          if (selected.isBefore(now)) {
                            selected = selected.add(const Duration(days: 1));
                          }
                          widget.onPause(selected);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: '30m',
                        child: Text('30 minutes'),
                      ),
                      const PopupMenuItem(
                        value: '1h',
                        child: Text('1 hour'),
                      ),
                      const PopupMenuItem(
                        value: 'custom',
                        child: Text('Custom time...'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '30 minutes',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Cancel button (Black, pill shape)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showDeleteAccountDialog(
  BuildContext context, {
  required VoidCallback onDelete,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => DeleteAccountDialog(onDelete: onDelete),
  );
}

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key, required this.onDelete});
  final VoidCallback onDelete;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkInput);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkInput() {
    final text = _controller.text.trim();
    setState(() {
      _canDelete = text == 'DELETE';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Close button (X) in top right
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular pink icon in top center
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFFF2D7A),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete your account?',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Custom list format subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'This will permanently delete:',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '→ Your profile and display name',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              '→ Your location history',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '→ Your membership in all circles',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'This cannot be undone.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Type DELETE to confirm:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                // Input field
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Bottom buttons row
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _canDelete
                            ? () {
                                Navigator.pop(context);
                                widget.onDelete();
                              }
                            : null,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF2D7A),
                          disabledForegroundColor: const Color(0xFFF3F4F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Delete my account',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _canDelete ? const Color(0xFFFF2D7A) : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Go back',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
