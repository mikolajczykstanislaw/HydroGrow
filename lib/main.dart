import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'SplashScreen.dart';
import 'firebase_options.dart'; // Upewnij się, że plik jest poprawnie zaimportowany

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Upewnij się, że ta linia jest obecna
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Błąd inicjalizacji Firebase: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

class Strings {
  static const String appTitle = 'HydroGrow';
}