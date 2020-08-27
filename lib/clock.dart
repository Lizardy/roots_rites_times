import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rootsritestimes/model.dart';

enum _themeElement {
  gradientStart,
  gradientEnd,
  cardBackground,
  text,
}

final Map<_themeElement, Color> _lightTheme = {
  _themeElement.gradientStart: Colors.orange,
  _themeElement.gradientEnd: Colors.amber,
  _themeElement.cardBackground: Colors.white.withOpacity(0.7),
  _themeElement.text: Colors.brown[900],
};

final _darkTheme = {
  _themeElement.gradientStart: Colors.deepPurple,
  _themeElement.gradientEnd: Colors.indigo,
  _themeElement.cardBackground: Colors.grey[300].withOpacity(0.7),
  _themeElement.text: Colors.indigo[900],
};

class RootsRitesTimesClock extends StatefulWidget {
  const RootsRitesTimesClock(this.model);

  final ClockModel model;

  @override
  _RootsRitesTimesClockState createState() => _RootsRitesTimesClockState();
}

class _RootsRitesTimesClockState extends State<RootsRitesTimesClock> {
  Map<_themeElement, Color> _colors;
  TextStyle _textStyleL;
  TextStyle _textStyleM;
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(RootsRitesTimesClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
          Duration(hours: 1) - Duration(minutes: _dateTime.minute),
          _updateTime
      );
      // Update once per minute. If you want to update every second, use the
      // following code.
//      _timer = Timer(
//        Duration(minutes: 1) -
//            Duration(seconds: _dateTime.second) -
//            Duration(milliseconds: _dateTime.millisecond),
//        _updateTime,
//      );
    });
  }

  Widget _dateTimeAspect(DateTimeStructure dateTimeStructure) {
    return Card(
      color: _colors[_themeElement.cardBackground],
      child: Container(
        height: 120,
        child: Column(
          children: [
            ListTile(
              title: Text(dateTimeStructure.str ?? dateTimeStructure.num.toString(), style: _textStyleL),
              subtitle: Text(dateTimeStructure.title),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${dateTimeStructure.num} of ${dateTimeStructure.ofNum}', style: _textStyleM),
              )],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    _textStyleL = TextStyle(color: _colors[_themeElement.text], fontSize: 22.0);
    _textStyleM = TextStyle(color: _colors[_themeElement.text], fontSize: 16.0);
//    final hour =
//        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final DateTimeBreakdown _dateTimeBreakdown = DateTimeBreakdown(_dateTime);

    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_colors[_themeElement.gradientStart], _colors[_themeElement.gradientEnd]],
        )),
        child: ListView.builder(
            itemCount: _dateTimeBreakdown.components.length,
            itemBuilder: (context, i){
              return _dateTimeAspect(_dateTimeBreakdown.components[i]);
            }
        ),
        );
  }
}

enum TimeOfDay { night, morning, afternoon, evening }

class DateTimeBreakdown {
  List<DateTimeStructure> components = [];

  static TimeOfDay timeOfDay(int hour) {
    if (hour >= 22 || hour < 5) return TimeOfDay.night;
    else if (hour >= 5 && hour < 12) return TimeOfDay.morning;
    else if (hour >= 12 && hour < 18) return TimeOfDay.afternoon;
    else if (hour >= 18 && hour < 22) return TimeOfDay.evening;
    else throw Exception('unable to determine time of the day');
  }

  static bool isLeapYear(int year) => year % 4 == 0 && year % 100 != 0 || year % 400 == 0;

  static int daysPerMonth(int month, int year) {
    if (month == 2)
      return isLeapYear(year) ? 29 : 28;
    else
      return [1, 3, 5, 7, 8, 10, 12].contains(month) ? 31 : 30;
  }

  DateTimeBreakdown(DateTime dateTime) {
    components.add(DateTimeStructure(
        dateTime.hour,
        24,
        'time of the day',
        str: describeEnum(timeOfDay(dateTime.hour))
    ));
    components.add(DateTimeStructure(
        dateTime.weekday,
        DateTime.daysPerWeek,
        'day of the week',
        str: DateFormat('EEEE').format(dateTime)
    ));
    components.add(DateTimeStructure(
        dateTime.day,
        daysPerMonth(dateTime.month, dateTime.year),
        'day of the month'
    ));
    components.add(DateTimeStructure(
        dateTime.month,
        DateTime.monthsPerYear,
        'month of the year',
        str: DateFormat('MMMM').format(dateTime)
    ));
  }
}

class DateTimeStructure {
  final int num;
  final int ofNum;
  final String title;
  final String str;

  const DateTimeStructure(this.num, this.ofNum, this.title, {this.str});
}
