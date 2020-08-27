import 'package:flutter/material.dart';
import 'package:rootsritestimes/clock.dart';
import 'customizer.dart';
import 'model.dart';

void main() {
  runApp(ClockCustomizer((ClockModel model) => RootsRitesTimesClock(model)));
}