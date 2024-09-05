import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:timesphere/login_screen.dart';
import 'package:timesphere/services/auth_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  int _buttonIndex = 0;
  final _widgets = [
    // Pending Tasks Widget
    Container(),
    
    // Completed Tasks Widget
    Container(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1d2630),
      appBar: AppBar(
        backgroundColor: Color(0xFF1d2630),
        foregroundColor: Colors.white,
        title: Text("TaskFlow", style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold
        ),),
        actions: [
          IconButton(onPressed: () async{
            await AuthService().signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          }, icon: Icon(Icons.exit_to_app))
        ],
      ),
    );
  }
}