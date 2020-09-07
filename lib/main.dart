import 'package:flutter/material.dart';
import 'package:rootsritestimes/clock.dart';
import 'customizer.dart';
import 'model.dart';

void main() {
  runApp(MaterialApp(
      title: 'Roots Rites Times',
      color: Colors.grey[700],
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: ClockCustomizer((ClockModel model) => RootsRitesTimesClock(model)),
  )
  );
}