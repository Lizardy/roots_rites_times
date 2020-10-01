import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rootsritestimes/clock.dart';
import 'package:rootsritestimes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';

enum Prefs { manuallySetDark }
enum MenuItems { switchTheme, autoSwitchTheme }

/// Returns a clock [Widget] with [ClockModel].
typedef Widget ClockBuilder(ClockModel model);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _themeManager = Provider.of<ThemeManager>(context);
    return MaterialApp(
      title: 'Roots Rites Times',
      theme: _themeManager.getTheme(),
      debugShowCheckedModeBanner: false,
      home: ClockCustomizer((ClockModel model) => RootsRitesTimesClock(model)),
    );
  }
}

/// Wrapper for clock widget to allow for customizations.
class ClockCustomizer extends StatefulWidget {
  const ClockCustomizer(this._clock);
  final ClockBuilder _clock;

  @override
  _ClockCustomizerState createState() => _ClockCustomizerState();
}

class _ClockCustomizerState extends State<ClockCustomizer> {
  final _model = ClockModel();

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

  void _handleModelChange() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    SharedPreferences.getInstance().then((prefs) {
      themeManager.updateTheme(
          prefs.getBool(describeEnum(Prefs.manuallySetDark)),
          _model.isDarkTimeOfDay
      );
      setState(() {});
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime dt = _model.dateTimeFixed == null
        ? DateTime.now()
        : _model.dateTimeFixed;
    final DateTime selected = await showDatePicker(
        context: context,
        initialDate: dt,
        firstDate: DateTime(1200),
        lastDate: DateTime(2200),
    );
    if (selected != null && selected != _model.dateTimeFixed) {
      setState(() {
        _model.dateTimeFixed = DateTime(
          selected.year,
          selected.month,
          selected.day,
          selected.hour + dt.hour,
          selected.minute + dt.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final DateTime dt = _model.dateTimeFixed == null
        ? DateTime.now()
        : _model.dateTimeFixed;
    final TimeOfDay selected = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: dt.hour,
            minute: dt.minute,
        ),
    );
    if (selected != null && selected != _model.dateTimeFixed) {
      setState(() {
        _model.dateTimeFixed = DateTime(
          dt.year,
          dt.month,
          dt.day,
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

  Widget popupMenu(SharedPreferences prefs) {
    final themeManager = Provider.of<ThemeManager>(context);
    return PopupMenuButton(
      onSelected: (selected) {
        switch (selected) {
          case MenuItems.switchTheme:
            themeManager.switchTheme();
            prefs.setBool(
                describeEnum(Prefs.manuallySetDark),
                themeManager.isThemeDark()
            );
            break;
          case MenuItems.autoSwitchTheme:
            prefs.setBool(
                describeEnum(Prefs.manuallySetDark),
                null
            );
            themeManager.updateTheme(null, _model.isDarkTimeOfDay);
            break;
        }
      },
      itemBuilder: (BuildContext context) =>
      [
        PopupMenuItem(
          value: MenuItems.switchTheme,
          child: Text('Switch color scheme'),
        ),
        PopupMenuItem(
          value: MenuItems.autoSwitchTheme,
          child: Text('Auto-switch color scheme'),
          enabled: prefs.getBool(describeEnum(Prefs.manuallySetDark)) != null
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget._clock(_model),
      appBar: AppBar(
        title: Row(children: [
          timePicker(),
          datePicker(),
          Spacer(),
          dayBack(),
          today(),
          dayForward(),
        ]),
        actions: [
          FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return snapshot.hasData
                  ? popupMenu(snapshot.data)
                  : Container();
            },
          )
        ],
      ),
    );
  }
}
