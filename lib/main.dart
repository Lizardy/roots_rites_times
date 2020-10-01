import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rootsritestimes/theme.dart';
import 'customizer.dart';

void main() {
  runApp(ChangeNotifierProvider<ThemeManager>(
    create: (context) => ThemeManager(darkTheme),
    child: App(),
  ));
}