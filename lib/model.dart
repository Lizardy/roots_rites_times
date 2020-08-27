import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// This is the model that contains the customization options for the clock.
///
/// It is a [ChangeNotifier], so use [ChangeNotifier.addListener] to listen to
/// changes to the model. Be sure to call [ChangeNotifier.removeListener] in
/// your `dispose` method.
class ClockModel extends ChangeNotifier {
  get is24HourFormat => _is24HourFormat;
  bool _is24HourFormat = true;

  set is24HourFormat(bool is24HourFormat) {
    if (_is24HourFormat != is24HourFormat) {
      _is24HourFormat = is24HourFormat;
      notifyListeners();
    }
  }
}