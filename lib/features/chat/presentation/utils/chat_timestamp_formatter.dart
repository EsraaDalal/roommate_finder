/// Formats timestamps for chat UI, e.g. "10:31 AM" or "Yesterday".
String formatChatTimestamp(DateTime time) {
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(time.year, time.month, time.day);

  final difference = today.difference(day).inDays;

  if (difference == 0) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  if (difference == 1) {
    return 'Yesterday';
  }

  return '${time.month}/${time.day}';
}