import 'package:intl/intl.dart';

enum PartOfDay { night, morning, afternoon, evening }

PartOfDay partOfDay(int hour) {
  if (hour >= 22 || hour < 5) return PartOfDay.night;
  else if (hour >= 5 && hour < 12) return PartOfDay.morning;
  else if (hour >= 12 && hour < 18) return PartOfDay.afternoon;
  else if (hour >= 18 && hour < 22) return PartOfDay.evening;
  else throw Exception('unable to determine part of day');
}

bool isDarkTimeOfDay(int hour) =>
    partOfDay(hour) == PartOfDay.night || partOfDay(hour) == PartOfDay.evening;

bool isLeapYear(int year) =>
    year % 4 == 0 && year % 100 != 0 || year % 400 == 0;

int daysPerMonth(int month, int year) {
  if (month == 2)
  return isLeapYear(year) ? 29 : 28;
  else
  return [1, 3, 5, 7, 8, 10, 12].contains(month) ? 31 : 30;
}

int dayOfYear(DateTime dt) => int.parse(DateFormat("D").format(dt));

DateTime lastDayOfPrevYear(int year) => DateTime(year - 1, 12, 31);

/// week years according to ISO 8601 standard:
/// the first week of year has a majority (4 or more) of its days in January
int weekOfYearCalculated(DateTime dt) =>
    ((dayOfYear(dt) - dt.weekday + 10) / 7).floor();

int weekOfYear(DateTime dt) {
  int weekNumber = weekOfYearCalculated(dt);
  return weekNumber == 0
      ? weekOfYearCalculated(lastDayOfPrevYear(dt.year))
      : weekNumber;
}

int weeksInYear(DateTime dt) {
  int weekNumber = weekOfYearCalculated(dt);
  return weekNumber == 0
      ? weekOfYearCalculated(lastDayOfPrevYear(dt.year))
      : weekOfYear(DateTime(dt.year, 12, 31));
}