import 'dart:async';
import 'dart:math';
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
  accent,
  faded,
}

final Map<_themeElement, ColorSwatch> _lightTheme = {
  _themeElement.gradientStart: Colors.orange,
  _themeElement.gradientEnd: Colors.amber,
  _themeElement.cardBackground: Colors.grey, //[100].withOpacity(0.7)
  _themeElement.text: Colors.brown, //[900]
  _themeElement.accent: Colors.amberAccent,
  _themeElement.faded: Colors.orange, //gradient to calculate
};

final Map<_themeElement, ColorSwatch> _darkTheme = {
  _themeElement.gradientStart: Colors.deepPurple,
  _themeElement.gradientEnd: Colors.indigo,
  _themeElement.cardBackground: Colors.grey, //[100].withOpacity(0.7)
  _themeElement.text: Colors.indigo, //[900]
  _themeElement.accent: Colors.blueAccent,
  _themeElement.faded: Colors.indigo, //gradient to calculate
};

class RootsRitesTimesClock extends StatefulWidget {
  const RootsRitesTimesClock(this.model);

  final ClockModel model;

  @override
  _RootsRitesTimesClockState createState() => _RootsRitesTimesClockState();
}

class _RootsRitesTimesClockState extends State<RootsRitesTimesClock> {
  Map<_themeElement, ColorSwatch>  _theme;
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
      color: _theme[_themeElement.cardBackground][100].withOpacity(0.7),
      child: Container(
        height: dateTimeStructure.visual == null ? 120 : 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListTile(
              title: Text(dateTimeStructure.str ?? dateTimeStructure.num.toString(), style: _textStyleL),
              subtitle: Text(dateTimeStructure.title),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: dateTimeStructure.visual == null ? Container() : Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(painter: dateTimeStructure.visual),
                ),
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text('${dateTimeStructure.num} of ${dateTimeStructure.ofNum}', style: _textStyleM),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text('< ${(dateTimeStructure.ofNum == 24
                        ? dateTimeStructure.ofNum - 1
                        : dateTimeStructure.ofNum
                    ) - dateTimeStructure.num + 1} to go', style: _textStyleM),
                  ),
                ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    _textStyleL = TextStyle(color: _theme[_themeElement.text], fontSize: 22.0);
    _textStyleM = TextStyle(color: _theme[_themeElement.text], fontSize: 18.0);
//    final hour =
//        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final DateTimeBreakdown _dateTimeBreakdown = DateTimeBreakdown(_dateTime, _theme);

    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _theme[_themeElement.gradientStart],
            _theme[_themeElement.gradientEnd]
          ],
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

  static bool isLeapYear(int year) => year % 4 == 0 && year % 100 != 0
      || year % 400 == 0;

  static int daysPerMonth(int month, int year) {
    if (month == 2)
      return isLeapYear(year) ? 29 : 28;
    else
      return [1, 3, 5, 7, 8, 10, 12].contains(month) ? 31 : 30;
  }

  DateTimeBreakdown(DateTime dateTime, Map<_themeElement, Color> theme) {
    components.add(DateTimeStructure(
        dateTime.hour,
        24,
        'time of the day',
        str: describeEnum(timeOfDay(dateTime.hour)),
        visual: TimeOfDayPainter(theme, dateTime.hour),
    ));
    components.add(DateTimeStructure(
        dateTime.weekday,
        DateTime.daysPerWeek,
        'day of the week',
        str: DateFormat('EEEE').format(dateTime),
        visual: DayOfWeekPainter(theme, dateTime.weekday),
    ));
    components.add(DateTimeStructure(
        dateTime.day,
        daysPerMonth(dateTime.month, dateTime.year),
        'day of the month',
        visual: DayOfMonthPainter(
            theme,
            dateTime.day,
            // dateTime.subtract(Duration(days: dateTime.day)).weekday,
            DateTime(dateTime.year, dateTime.month, 1).weekday,
            daysPerMonth(dateTime.month, dateTime.year),
        )
    ));
    components.add(DateTimeStructure(
        dateTime.month,
        DateTime.monthsPerYear,
        'month of the year',
        str: DateFormat('MMMM').format(dateTime),
        visual: MonthOfYearPainter(theme, dateTime.month)
    ));
  }
}

class DateTimeStructure {
  final int num;
  final int ofNum;
  final String title;
  final String str;
  final CustomPainter visual;

  const DateTimeStructure(this.num, this.ofNum, this.title, {this.str, this.visual});
}

class TimeOfDayPainter extends CustomPainter {
  final Map<_themeElement, ColorSwatch> _theme;
  final int _currentHour;

  const TimeOfDayPainter(this._theme, this._currentHour);

  @override
  void paint(Canvas canvas, Size size) {
    const hourInDegrees = 30;
    const halfDay = 12;
    const angleSweepInRadians = (hourInDegrees-90) * pi / 360.0;
    final num radius = min(size.width / 4, size.height / 2);
    final centerAM = Offset(radius, radius);
    final centerPM = Offset(radius * 3, radius);
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = _theme[_themeElement.text][900];
    final paintAccent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = _theme[_themeElement.accent];
    // draw the base circles
    canvas.drawCircle(centerAM, radius, paintStroke);
    canvas.drawCircle(centerPM, radius, paintStroke);
    // fill the past and current hours with gradient (the closer to current, the brighter)
    Offset centerCurrent = _currentHour < halfDay ? centerAM : centerPM;
    Offset centerPast = _currentHour >= halfDay ? centerAM : null;
    int currentHour12 = _currentHour >= halfDay ? _currentHour - 12 : _currentHour;
    num angleInDegrees;
    num angleInRadians;
    int colorIndex = 700;
    Paint paintFill = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 6.0
      ..color = _theme[_themeElement.faded][colorIndex];
    for (int i = currentHour12; i >= 0; i--) {
      angleInDegrees = 30 * i;
      angleInRadians = (angleInDegrees-90) * pi / 180.0;
      canvas.drawArc(
          Rect.fromCircle(center: centerCurrent, radius: radius),
          angleInRadians,
          -angleSweepInRadians,
          true,
          paintFill
      );
      if (i % 2 == 0) colorIndex -= 100;
      paintFill = Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = 6.0
        ..color = _theme[_themeElement.faded][colorIndex];
    }
    if (centerPast != null) {
      canvas.drawCircle(centerPast, radius, paintFill);
    }
//    double x = radius*cos(pi/-2+(2*_currentHour*pi)/12)+centerCurrent.dx;
//    double y = radius*sin(pi/-2+(2*_currentHour*pi)/12)+centerCurrent.dy;
//    var pointCurrentHour = Offset(x,y); // point on circle
    // draw an accent line to mark the current hour on top of all
    angleInDegrees = 30 * _currentHour;
    angleInRadians = (angleInDegrees-90) * pi / 180.0;
    canvas.drawArc(
        Rect.fromCircle(center: centerCurrent, radius: radius),
        angleInRadians,
        -angleSweepInRadians,
        true,
        paintAccent
    );

  }

  @override
  bool shouldRepaint(TimeOfDayPainter oldDelegate) =>
      _currentHour != oldDelegate._currentHour || _theme != oldDelegate._theme;
}

class DayOfWeekPainter extends CustomPainter {
  final Map<_themeElement, ColorSwatch> _theme;
  final int _currentDay;

  const DayOfWeekPainter(this._theme, this._currentDay);

  @override
  void paint(Canvas canvas, Size size) {
    final num squareSize = size.width / DateTime.daysPerWeek;
    final num top = size.height / 2 - squareSize / 2;
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = _theme[_themeElement.text][900];
    final paintAccent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = _theme[_themeElement.accent];
    for (int i = 0; i < DateTime.daysPerWeek; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * squareSize, top, squareSize, squareSize),
        paintStroke,
      );
      if (i + 1 <= _currentDay) {
        int _fadedIndex = DateTime.daysPerWeek * 100 -
            (i + 1 - _currentDay).abs() * 100;
        canvas.drawRect(
          Rect.fromLTWH(i * squareSize, top, squareSize, squareSize),
          Paint()
            ..style = PaintingStyle.fill
            ..color = _theme[_themeElement.faded][_fadedIndex],
        );
      }
    }
    // draw an accent square to mark the current value on top of all
    canvas.drawRect(
      Rect.fromLTWH((_currentDay - 1) * squareSize, top, squareSize, squareSize),
      paintAccent,
    );
  }

  @override
  bool shouldRepaint(DayOfWeekPainter oldDelegate) =>
      _currentDay != oldDelegate._currentDay || _theme != oldDelegate._theme;
}

class DayOfMonthPainter extends CustomPainter {
  final Map<_themeElement, ColorSwatch> _theme;
  final int _currentDay;
  final int _firstDay; // weekday of the first day of month
  final int _lastDay; // last day of month

  const DayOfMonthPainter(this._theme, this._currentDay, this._firstDay, this._lastDay);

  @override
  void paint(Canvas canvas, Size size) {
    const int numPerRow = DateTime.daysPerWeek;
    final int numRows = ((_lastDay + _firstDay) / numPerRow).ceil();
    final num squareSize = min(size.width / numPerRow, size.height / numRows);
    final num horizontalOffset = (size.width - squareSize * numPerRow) / 2;
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = _theme[_themeElement.text][900];
    final paintSpace = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.transparent;
    final paintAccent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = _theme[_themeElement.accent];
    int fadedIndex = 600;
    int dayOfMonth = 1;
    num fromTop, fromLeft;
    for (int week = 0; week < numRows; week++)
      for (int day = 0; day < numPerRow; day++) {
        fromTop = week * squareSize;
        fromLeft = day * squareSize + horizontalOffset;
        if ((week == 0 && day < _firstDay-1 && _firstDay != 1)
            || dayOfMonth > _lastDay) {
          canvas.drawRect(
            Rect.fromLTWH(fromLeft, fromTop, squareSize, squareSize),
            paintSpace,
          );
        } else {
          canvas.drawRect(
            Rect.fromLTWH(fromLeft, fromTop, squareSize, squareSize),
            paintStroke,
          );
          if (dayOfMonth <= _currentDay) {
            canvas.drawRect(
              Rect.fromLTWH(fromLeft, fromTop, squareSize, squareSize),
              Paint()
                ..style = PaintingStyle.fill
                ..color = _theme[_themeElement.faded][fadedIndex -
                    (((_currentDay - 1 + _firstDay - 1) / numRows).floor()
                        - 1 - week) * 100],
            );
          }
          dayOfMonth++;
        }
      }
    // draw an accent square on top of all to mark the current day
    fromTop = (((_currentDay - 1 + _firstDay - 1) / numPerRow).floor())
        * squareSize;
    fromLeft = (_currentDay - 1 -
        ((_currentDay - 1 + _firstDay - 1) / numPerRow).floor() * numPerRow +
        _firstDay - 1) * squareSize+horizontalOffset;
    canvas.drawRect(
      Rect.fromLTWH(fromLeft, fromTop, squareSize, squareSize),
      paintAccent,
    );
  }

  @override
  bool shouldRepaint(DayOfMonthPainter oldDelegate) =>
      _currentDay != oldDelegate._currentDay || _theme != oldDelegate._theme ||
          _firstDay != oldDelegate._firstDay || _lastDay != oldDelegate._lastDay;
}

class MonthOfYearPainter extends CustomPainter {
  final Map<_themeElement, ColorSwatch> _theme;
  final int _currentMonth;

  const MonthOfYearPainter(this._theme, this._currentMonth);

  @override
  void paint(Canvas canvas, Size size) {
    final int numPerRow = (DateTime.monthsPerYear / 2).floor();
    final num squareSize = size.width / numPerRow;
    final num top = size.height / 2 - squareSize;
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = _theme[_themeElement.text][900];
    final paintAccent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = _theme[_themeElement.accent];
    for (int i = 0, j = DateTime.monthsPerYear - 1; i < DateTime.monthsPerYear; i++, j--) {
      num fromTop = i < DateTime.monthsPerYear/2 ? top : top+squareSize;
      num fromLeft = i < DateTime.monthsPerYear/2 ? i * squareSize : j * squareSize;
      canvas.drawRect(
        Rect.fromLTWH(fromLeft, fromTop, squareSize, squareSize),
        paintStroke,
      );
      if (i < _currentMonth) {
        int _fadedIndex = (numPerRow + 1) * 100 -
            ((_currentMonth - i) / 2).ceil() * 100;
        canvas.drawRect(
          Rect.fromLTWH(fromLeft, fromTop, squareSize, squareSize),
          Paint()
            ..style = PaintingStyle.fill
            ..color = _theme[_themeElement.faded][_fadedIndex],
        );
      }
    }
    // draw an accent square to mark the current value on top of all
    num fromTop = _currentMonth <= DateTime.monthsPerYear/2
        ? top
        : top + squareSize;
    num fromLeft = _currentMonth <= DateTime.monthsPerYear/2
        ? (_currentMonth - 1) * squareSize
        : (DateTime.monthsPerYear - _currentMonth) * squareSize;
    canvas.drawRect(
      Rect.fromLTWH(fromLeft, fromTop, squareSize, squareSize),
      paintAccent,
    );
  }

  @override
  bool shouldRepaint(MonthOfYearPainter oldDelegate) =>
      _currentMonth != oldDelegate._currentMonth || _theme != oldDelegate._theme;
}