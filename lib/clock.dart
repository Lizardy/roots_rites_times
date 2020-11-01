import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rootsritestimes/dt_helpers.dart';
import 'package:rootsritestimes/model.dart';
import 'package:rootsritestimes/theme.dart';

class RootsRitesTimesClock extends StatefulWidget {
  const RootsRitesTimesClock(this.model);

  final ClockModel model;

  @override
  _RootsRitesTimesClockState createState() => _RootsRitesTimesClockState();
}

class _RootsRitesTimesClockState extends State<RootsRitesTimesClock> with WidgetsBindingObserver{
  /// DateTime to display, can be current or manually selected
  DateTime _dateTime;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.model.addListener(_updateModel);
    _dateTime = widget.model.dateTimeFixed;
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateTime();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateModel() {
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      if (widget.model.dateTimeFixed == null) {
        _dateTime = DateTime.now();
      } else {
        Duration diff = _dateTime.difference(widget.model.dateTimeFixed);
        if (diff.inHours.abs() >= 1) {
          _dateTime = widget.model.dateTimeFixed;
          _updateTime();
        }
      }
      widget.model.isDarkTimeOfDay = isDarkTimeOfDay(_dateTime.hour);
      Duration _time = Duration(hours: 1) -
          Duration(minutes: _dateTime.minute) -
          Duration(seconds: _dateTime.second);
      print('next update in ${_time.inMinutes} minutes');
      _timer = Timer(_time, _updateTime);
    });
  }

  Widget _dateTimeAspect(DateTimeStructure dateTimeStructure) {
    num _cardH = MediaQuery.of(context).size.height / 2.3;
    ThemeData _theme = Theme.of(context);
    return Card(
      color: _theme.cardColor.withOpacity(_theme.brightness == Brightness.dark
          ? 0.2
          : 0.6
      ),
      child: Container(
        height: dateTimeStructure.visual == null ? _cardH / 2 : _cardH,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListTile(
              title: Text(dateTimeStructure.str ?? dateTimeStructure.num.toString()),
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
                    child: Text('${dateTimeStructure.num} of ${dateTimeStructure.ofNum}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text('< ${(dateTimeStructure.ofNum == 24
                        ? dateTimeStructure.ofNum - 1
                        : dateTimeStructure.ofNum
                    ) - dateTimeStructure.num + 1} to go'),
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
    final DateTimeBreakdown _dateTimeBreakdown = DateTimeBreakdown(_dateTime, context);

    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).backgroundColor,
                Theme.of(context).scaffoldBackgroundColor,
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

class DateTimeBreakdown {
  List<DateTimeStructure> components = [];

  DateTimeBreakdown(DateTime dateTime, BuildContext context) {
    final int currentWeekOfYear = weekOfYear(dateTime);
    final int weeksInTheYear = weeksInYear(dateTime);
    components.add(DateTimeStructure(
        dateTime.hour,
        24,
        'time of the day',
        str: describeEnum(partOfDay(dateTime.hour)),
        visual: TimeOfDayPainter(context, dateTime.hour),
    ));
    components.add(DateTimeStructure(
        dateTime.weekday,
        DateTime.daysPerWeek,
        'day of the week',
        str: DateFormat('EEEE').format(dateTime),
        visual: DayOfWeekPainter(context, dateTime.weekday),
    ));
    components.add(DateTimeStructure(
        currentWeekOfYear,
        weeksInTheYear,
        'week of the year',
        str: currentWeekOfYear.toString(),
        visual: WeekOfYearPainter(context, currentWeekOfYear, weeksInTheYear)
    ));
    components.add(DateTimeStructure(
        dateTime.day,
        daysPerMonth(dateTime.month, dateTime.year),
        'day of the month',
        visual: DayOfMonthPainter(
            context,
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
        visual: MonthOfYearPainter(context, dateTime.month)
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
  final BuildContext _context;
  final int _currentHour;

  const TimeOfDayPainter(this._context, this._currentHour);

  @override
  void paint(Canvas canvas, Size size) {
    const hourInDegrees = 30;
    const halfDay = 12;
    const angleSweepInRadians = (hourInDegrees - 90) * pi / 360.0;
    const offsetHBetween = 2;
    final num radius = min(size.width / 4, size.height / 2);
    final num offsetH = (size.width - radius * 4 - offsetHBetween) / 2;
    final centerAM = Offset(radius + offsetH, radius);
    final centerPM = Offset(radius * 3 + offsetH + offsetHBetween, radius);
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Theme.of(_context).cursorColor;
    final paintAccent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = Theme.of(_context).accentColor;
    // draw the base circles
    canvas.drawCircle(centerAM, radius, paintStroke);
    canvas.drawCircle(centerPM, radius, paintStroke);
    // fill the past and current hours with gradient
    // (the closer to current, the brighter)
    Offset centerCurrent = _currentHour < halfDay ? centerAM : centerPM;
    Offset centerPast = _currentHour >= halfDay ? centerAM : null;
    int currentHour12 = _currentHour >= halfDay ? _currentHour - 12 : _currentHour;
    num angleInDegrees;
    num angleInRadians;
    int colorIndex = 800;
    MaterialColor primarySwatch = getSwatch(Theme.of(_context).primaryColor);
    Paint paintFill = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 6.0
      ..color = primarySwatch[colorIndex];
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
        ..color = primarySwatch[colorIndex];
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
      _currentHour != oldDelegate._currentHour;
}

class DayOfWeekPainter extends CustomPainter {
  final BuildContext _context;
  final int _currentDay;

  const DayOfWeekPainter(this._context, this._currentDay);

  @override
  void paint(Canvas canvas, Size size) {
    final num squareSize = size.width / DateTime.daysPerWeek;
    final num top = size.height / 2 - squareSize / 2;
    MaterialColor primarySwatch = getSwatch(Theme.of(_context).primaryColor);
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Theme.of(_context).cursorColor;
    final paintAccent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = Theme.of(_context).accentColor;
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
            ..color = primarySwatch[_fadedIndex],
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
      _currentDay != oldDelegate._currentDay;
}

class WeekOfYearPainter extends CustomPainter {
  final BuildContext _context;
  final int _currentWeek;
  final int _weeksInCurrentYear;

  const WeekOfYearPainter(this._context, this._currentWeek, this._weeksInCurrentYear);

  @override
  void paint(Canvas canvas, Size size) {
    final num height = size.height / 4;
    final int numPerRow = (_weeksInCurrentYear / 2).ceil();
    final num width = size.width / numPerRow;
    final num top = size.height / 2 - height;
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Theme.of(_context).cursorColor;
    final paintAccent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = Theme.of(_context).accentColor;
    MaterialColor primarySwatch = getSwatch(Theme.of(_context).primaryColor);
    for (int i = 0, j = _weeksInCurrentYear-1; i < _weeksInCurrentYear; i++, j--) {
      num fromTop, fromLeft;
      if (numPerRow % 2 == 0) {
        // 52 weeks in a year, 26 elements per row
        if (i < numPerRow) {
          fromTop = top;
          fromLeft = i * width;
        } else {
          fromTop = top + height;
          fromLeft = (i - numPerRow) * width;
        }
      } else {
        // 53 weeks in a year, 26 elements per row + appendix
        if (i < numPerRow - 1) {
          fromTop = top;
          fromLeft = i * width;
        } else if (i == numPerRow - 1) {
          fromTop = top + height / 2;
          fromLeft = i * width;
        } else {
          fromTop = top + height;
          fromLeft = j * width;
        }
      }
      canvas.drawRect(
        Rect.fromLTWH(fromLeft, fromTop, width, height),
        paintStroke,
      );
      if (i < _currentWeek) {
        // every 6 elements change shade, 9 shades total, 6*9=54 (53,52)
        int fadedIndex = 1000 - ((_currentWeek - i) / 6).ceil() * 100;
        canvas.drawRect(
          Rect.fromLTWH(fromLeft, fromTop, width, height),
          Paint()
            ..style = PaintingStyle.fill
            ..color = primarySwatch[fadedIndex],
        );
      }
    }
    // draw an accent square to mark the current value on top of all
    num fromTop = _currentWeek <= _weeksInCurrentYear / 2
        ? top
        : top + height;
    num fromLeft = _currentWeek <= _weeksInCurrentYear / 2
        ? (_currentWeek - 1) * width
        : (_weeksInCurrentYear - _currentWeek) * width;
    canvas.drawRect(
      Rect.fromLTWH(fromLeft, fromTop, width, height),
      paintAccent,
    );
  }

  @override
  bool shouldRepaint(WeekOfYearPainter oldDelegate) =>
      _currentWeek != oldDelegate._currentWeek
          || _weeksInCurrentYear != oldDelegate._weeksInCurrentYear;
}

class DayOfMonthPainter extends CustomPainter {
  final BuildContext _context;
  final int _currentDay;
  final int _firstDay; // weekday of the first day of month
  final int _lastDay; // last day of month

  const DayOfMonthPainter(this._context, this._currentDay, this._firstDay, this._lastDay);

  @override
  void paint(Canvas canvas, Size size) {
    const int numPerRow = DateTime.daysPerWeek;
    final int numRows = ((_lastDay + _firstDay) / numPerRow).ceil();
    final num squareSize = min(size.width / numPerRow, size.height / numRows);
    final num horizontalOffset = (size.width - squareSize * numPerRow) / 2;
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Theme.of(_context).cursorColor;
    final paintSpace = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.transparent;
    final paintAccent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = Theme.of(_context).accentColor;
    MaterialColor primarySwatch = getSwatch(Theme.of(_context).primaryColor);
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
                ..color = primarySwatch[fadedIndex -
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
      _firstDay != oldDelegate._firstDay || _lastDay != oldDelegate._lastDay;
}

class MonthOfYearPainter extends CustomPainter {
  final BuildContext _context;
  final int _currentMonth;

  const MonthOfYearPainter(this._context, this._currentMonth);

  @override
  void paint(Canvas canvas, Size size) {
    final int numPerRow = (DateTime.monthsPerYear / 2).floor();
    final num squareSize = size.width / numPerRow;
    final num top = size.height / 2 - squareSize;
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Theme.of(_context).cursorColor;
    final paintAccent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = Theme.of(_context).accentColor;
    MaterialColor primarySwatch = getSwatch(Theme.of(_context).primaryColor);
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
            ..color = primarySwatch[_fadedIndex],
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
      _currentMonth != oldDelegate._currentMonth;
}