import 'package:flutter/material.dart';

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
  backgroundColor: Colors.indigo,
  scaffoldBackgroundColor: Colors.indigoAccent,
  accentColor: Colors.blueAccent,
  cursorColor: Colors.white30
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
  cardColor: Colors.grey[100],
  backgroundColor: Colors.orangeAccent,
  scaffoldBackgroundColor: Colors.orange,
  accentColor: Colors.amberAccent,
  cursorColor: Colors.brown[900],
);

class ThemeManager with ChangeNotifier {
  ThemeData _themeData;

  ThemeManager(this._themeData);

  getTheme() => _themeData;
  setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }
  void updateTheme(bool manuallySetDark, bool isDarkTimeOfDay) {
    if (manuallySetDark == true) {
      setTheme(darkTheme);
    } else if (manuallySetDark == false) {
      setTheme(lightTheme);
    } else if (manuallySetDark == null) {
      setTheme(isDarkTimeOfDay ? darkTheme : lightTheme);
    }
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

