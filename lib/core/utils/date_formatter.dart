abstract final class DateFormatter {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String dateTime(DateTime value) =>
      '${_two(value.day)} ${_months[value.month - 1]} ${value.year}, '
      '${_two(value.hour)}:${_two(value.minute)}';

  static String date(DateTime value) =>
      '${_two(value.day)} ${_months[value.month - 1]} ${value.year}';

  static String time(DateTime value) =>
      '${_two(value.hour)}:${_two(value.minute)}';

  static String day(DateTime value) =>
      '${_days[value.weekday - 1]}, ${_two(value.day)} '
      '${_months[value.month - 1]}';

  static String shortDay(DateTime value) =>
      '${_two(value.day)}/${_two(value.month)}';

  static String month(DateTime value) =>
      '${_months[value.month - 1]} ${value.year}';

  static String relative(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return date(value);
  }
}
