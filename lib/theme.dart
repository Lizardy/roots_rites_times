import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rootsritestimes/customizer.dart';
import 'package:rootsritestimes/dt_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(color: Colors.grey[800]),
  primaryColor: Colors.indigo,
  textTheme: TextTheme(
    subtitle1: TextStyle(color: Colors.blue[200], fontWeight: FontWeight.bold),
    bodyText2: TextStyle(color: Colors.blue[100]),
    caption: TextStyle(color: Colors.blue[100]),
    button: TextStyle(color: Colors.white),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.grey[800],
    textStyle: TextStyle(color: Colors.white),
  ),
  cardColor: Colors.grey[700],
  backgroundColor: Colors.grey[800],
  scaffoldBackgroundColor: Colors.blueGrey,
  accentColor: Colors.blueAccent,
  cursorColor: Colors.blueGrey[300]
);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(color: Colors.orange[50]),
  primaryColor: Colors.orange,
  textTheme: TextTheme(
    subtitle1: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold),
    bodyText2: TextStyle(color: Colors.brown[700]),
    caption: TextStyle(color: Colors.brown[700]),
    button: TextStyle(color: Colors.black87),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.orange[50],
    textStyle: TextStyle(color: Colors.black),
  ),
  cardColor: Colors.orange[50],
  backgroundColor: Colors.orange[50],
  scaffoldBackgroundColor: Colors.amber[300],
  accentColor: Colors.amberAccent,
  cursorColor: Colors.brown[700],
);

class ThemeManager with ChangeNotifier {
  ThemeData _themeData;

  ThemeManager(this._themeData);
  ThemeManager.initial() {
    updateTheme(isDarkTimeOfDay(DateTime.now().hour));
  }

  getTheme() => _themeData;
  setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }
  void updateTheme(bool isDarkTimeOfDay) {
    SharedPreferences.getInstance().then((prefs) {
      bool manuallySetDark = prefs.getBool(describeEnum(Prefs.manuallySetDark));
      if (manuallySetDark == true) {
        setTheme(darkTheme);
      } else if (manuallySetDark == false) {
        setTheme(lightTheme);
      } else if (manuallySetDark == null) {
        setTheme(isDarkTimeOfDay ? darkTheme : lightTheme);
      }
    });
  }
  void switchTheme() {
    if (_themeData.brightness == Brightness.light)
      setTheme(darkTheme);
    else if (_themeData.brightness == Brightness.dark)
      setTheme(lightTheme);
  }
  bool isThemeDark() => _themeData.brightness == Brightness.dark;
}

MaterialColor getSwatch(Color color) => Colors.primaries
    .firstWhere((element) => element.value == color.value);

