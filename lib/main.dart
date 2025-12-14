import 'package:flutter/material.dart';
//import 'package:the_app/screens/homescreen.dart';
import 'package:trackivore/screens/settings.dart';
import 'package:trackivore/screens/setup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Bottom Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      //darkTheme: ThemeData.dark(),
      //themeMode: ThemeMode.system,
      supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
      initialRoute: '/',
      routes: {'/': (context) => Setup(), '/settings': (context) => Settings()},
    );
  }
}
