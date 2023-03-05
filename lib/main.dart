//import files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './screens/homeScreen.dart';
import 'screens/login_signup.dart';

void main() async {
  //firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //check whether if user sign in or not
        if (snapshot.hasData && snapshot.data != null) {
          // After user is signed in, navigate to the Home screen page
          return MaterialApp(
            title: 'Recipe Application',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: HomeScreen(),
          );
        } else {
          // If User is not signed in, navigate to the login page
          return const LoginScreen();
        }
      },
    );
  }
}
