import 'package:intl/intl.dart';

String dateStr(DateTime datetime) {
  return datetime.toString().substring(0, 10);
}

DateTime datetimeFromTimestamp(int unixtimestamp) {
  return DateTime.fromMillisecondsSinceEpoch(unixtimestamp * 1000);
}

String datetimeStr(int unixtimestamp) {
  return dateStr(datetimeFromTimestamp(unixtimestamp)).toString();
}

int currentTimestamp() {
  return timestamp(DateTime.now());
}

int currentTimeInt() {
  final now = DateTime.now();
  return int.parse(DateFormat('HHmmss').format(now));
}

int timestamp(DateTime datetime) {
  return datetime.millisecondsSinceEpoch ~/ 1000;
}
