import 'package:echo_chamber/pages/home_page.dart';
import 'package:echo_chamber/pages/login_page.dart';
import 'package:echo_chamber/pages/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        HomePage.route: (context) => const HomePage(title: 'Flutter Demo Home Page'),
        LoginPage.route: (context) => const LoginPage(),
        MapPage.route: (context) => const MapPage(),
      },
    );
  }
}
