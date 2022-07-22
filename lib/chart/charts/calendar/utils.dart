
extension DateTimeExtension on DateTime {
  int maxDay() {
    int curYear = year;
    int curMonth = month;
    if (curMonth < 12) {
      curMonth += 1;
    } else {
      curMonth = 1;
      curYear += 1;
    }
    return DateTime(curYear, curMonth, 0).day;
  }

  bool isAfterDay(DateTime time) {
    if (year < time.year) {
      return false;
    }
    if (year > time.year) {
      return true;
    }
    if (month < time.month) {
      return false;
    }
    if (month > time.month) {
      return true;
    }
    return day > time.day;
  }

  bool isBeforeDay(DateTime time) {
    if (year < time.year) {
      return true;
    }
    if (year > time.year) {
      return false;
    }
    if (month < time.month) {
      return true;
    }
    if (month > time.month) {
      return false;
    }
    return day < time.day;
  }

  bool isSameDay(DateTime time) {
    return year == time.year && month == time.month && day == time.day;
  }
}
