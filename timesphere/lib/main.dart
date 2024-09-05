import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timesphere/login_screen.dart';
import 'package:timesphere/signup_screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await dotenv.load(fileName: ".env");
  runApp(
   const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TaskFlow",
      theme: ThemeData(primarySwatch: Colors.indigo, primaryColor: Colors.indigo),
      home:  SignupScreen(),
    );
  }
}


