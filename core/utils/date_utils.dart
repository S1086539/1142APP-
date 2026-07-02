import 'package:intl/intl.dart';

String getWeekDay(DateTime date) {
  return DateFormat('EEEE', 'zh_TW').format(date).replaceAll('星期', '週');
}