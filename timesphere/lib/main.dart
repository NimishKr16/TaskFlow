import 'package:TaskFlow/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:TaskFlow/home_screen.dart';
import 'package:TaskFlow/login_screen.dart';
// import 'package:timesphere/signup_screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await dotenv.load(fileName: ".env");
  runApp(
    MyApp()
  );
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TaskFlow",
      theme: ThemeData(primarySwatch: Colors.indigo, primaryColor: Colors.indigo),
      home:  _auth.currentUser != null ? HomeScreen() : LoginScreen(),
    );
  }
}


