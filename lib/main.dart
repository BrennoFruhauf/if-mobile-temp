import 'package:flutter/material.dart';
import 'package:laura/constants/routes.dart';
import 'package:laura/screens/home_screen.dart';
import 'package:laura/screens/login_screen.dart';
import 'package:laura/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:laura/screens/splash_screen.dart';
import 'package:laura/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Finanças',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
        ),
      ),
      initialRoute: Routes.root,
      routes: {
        Routes.root: (context) => const SplashScreen(),
        Routes.login: (context) => const LoginScreen(),
        Routes.register: (context) => const RegisterScreen(),
        Routes.home: (context) => const HomeScreen(),
      },
    );
  }
}
