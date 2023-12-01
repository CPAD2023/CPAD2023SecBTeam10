import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login.dart';
import 'signup_page.dart';
import 'ProjectSelectionPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash', // Set splash as the initial route
      routes: {
        '/splash': (context) => SplashScreen(), // Add the splash screen route
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/project_selection': (context) => ProjectSelectionPage(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Text('Welcome to the Home Screen!'),
      ),
    );
  }
}
