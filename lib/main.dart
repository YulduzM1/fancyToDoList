import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/login_screen.dart'; // Import the login screen
import 'pages/signup_screen.dart'; // Import the signup screen
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(
            210,
            224,
            251,
            1,
          ),
        ),
        useMaterial3: true,
      ),
      // Replace home with initialRoute and routes
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(), // Set the login screen as the initial route
        '/signup': (context) => SignupScreen(), // Define the route for the signup screen
        '/home': (context) => const HomePage(), // Define the route for the home page
      },
    );
  }
}