import 'package:flutter/material.dart';

import 'model.dart';

/// Returns a clock [Widget] with [ClockModel].
typedef Widget ClockBuilder(ClockModel model);

/// Wrapper for clock widget to allow for customizations.
class ClockCustomizer extends StatefulWidget {
  const ClockCustomizer(this._clock);
  final ClockBuilder _clock;

  @override
  _ClockCustomizerState createState() => _ClockCustomizerState();
}

class _ClockCustomizerState extends State<ClockCustomizer> {
  final _model = ClockModel();
  ThemeMode _themeMode = ThemeMode.light;
  bool _configButtonShown = false;

  @override
  void initState() {
    super.initState();
    _model.dateTimeFixed = null;
    _model.addListener(_handleModelChange);
  }

  @override
  void dispose() {
    _model.removeListener(_handleModelChange);
    _model.dispose();
    super.dispose();
  }

  void _handleModelChange() => setState(() {});

  Future<void> _selectDate(BuildContext context) async {
    final DateTime selected = await showDatePicker(
        context: context,
        initialDate: _model.dateTimeFixed ?? DateTime.now(),
        firstDate: DateTime(1200),
        lastDate: DateTime(2200),
    );
    if (selected != null && selected != _model.dateTimeFixed) {
      setState(() {
        _model.dateTimeFixed = DateTime(
          selected.year,
          selected.month,
          selected.day,
          selected.hour + (_model.dateTimeFixed == null
              ? DateTime.now().hour
              : _model.dateTimeFixed.hour
          ),
          selected.minute + (_model.dateTimeFixed == null
              ? DateTime.now().minute
              : _model.dateTimeFixed.minute
          ),
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay selected = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: _model.dateTimeFixed.hour,
            minute: _model.dateTimeFixed.minute,
        ),
    );
    if (selected != null && selected != _model.dateTimeFixed) {
      setState(() {
        _model.dateTimeFixed = DateTime(
          _model.dateTimeFixed.year,
          _model.dateTimeFixed.month,
          _model.dateTimeFixed.day,
          selected.hour,
          selected.minute,
        );
      });
    }
  }

  Widget datePicker() {
    return IconButton(
        icon: Icon(Icons.event),
        tooltip: "Select date",
        onPressed: () => _selectDate(context),
    );
  }

  Widget timePicker() {
    return IconButton(
        icon: Icon(Icons.alarm),
        tooltip: "Select time",
        onPressed: () => _selectTime(context),
    );
  }

  Widget today() {
    return IconButton(
        icon: Icon(Icons.calendar_today),
        tooltip: "Today",
        onPressed: _model.dateTimeFixed == null ? null : () => setState(() {
          _model.dateTimeFixed = null;
        })
    );
  }

  Widget dayBack() {
    return IconButton(
      icon: Icon(Icons.arrow_left),
      tooltip: "Back into the past",
      onPressed: () => setState(() {
        _model.dateTimeFixed ??= DateTime.now();
        _model.dateTimeFixed = DateTime(
          _model.dateTimeFixed.year,
          _model.dateTimeFixed.month,
          _model.dateTimeFixed.day - 1,
          _model.dateTimeFixed.hour,
          _model.dateTimeFixed.minute,
        );
      }),
    );
  }

  Widget dayForward() {
    return IconButton(
      icon: Icon(Icons.arrow_right),
      tooltip: "Forward into the future",
      onPressed: () => setState(() {
        _model.dateTimeFixed ??= DateTime.now();
        _model.dateTimeFixed = DateTime(
          _model.dateTimeFixed.year,
          _model.dateTimeFixed.month,
          _model.dateTimeFixed.day + 1,
          _model.dateTimeFixed.hour,
          _model.dateTimeFixed.minute,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: widget._clock(_model),
        appBar: AppBar(
          backgroundColor: Colors.grey[700],
          iconTheme: IconThemeData(color: Colors.amberAccent),
          title: Row(children: [
            timePicker(),
            datePicker(),
            Spacer(),
            dayBack(),
            today(),
            dayForward(),
          ]),
        ),
      );
  }
}
