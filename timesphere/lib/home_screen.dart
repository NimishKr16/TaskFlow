import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:TaskFlow/login_screen.dart';
import 'package:TaskFlow/model/todo_model.dart';
import 'package:TaskFlow/services/auth_services.dart';
import 'package:TaskFlow/services/database_services.dart';
import 'package:TaskFlow/widgets/completed_widget.dart';
import 'package:TaskFlow/widgets/pending_widgets.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _buttonIndex = 0;
  final _widgets = [
    // Pending Tasks Widget
    PendingWidgets(),

    // Completed Tasks Widget
    CompletedWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1d2630),
      appBar: AppBar(
        backgroundColor: Color(0xFF1d2630),
        foregroundColor: Colors.white,
        title: Text(
          "TaskFlow",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _buttonIndex = 0;
                    });
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.2,
                    decoration: BoxDecoration(
                      color: _buttonIndex == 0 ? Colors.indigo : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Pending",
                        style: TextStyle(
                            fontSize: _buttonIndex == 0 ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: _buttonIndex == 0
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _buttonIndex = 1;
                    });
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.2,
                    decoration: BoxDecoration(
                      color: _buttonIndex == 1 ? Colors.indigo : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Completed",
                        style: TextStyle(
                            fontSize: _buttonIndex == 1 ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: _buttonIndex == 1
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
            _widgets[_buttonIndex],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: () {
            _showTaskDialog(context);
          }),
    );
  }

  void _showTaskDialog(BuildContext context, {Todo? todo}) {
    final TextEditingController _titleController =
        TextEditingController(text: todo?.title);
    final TextEditingController _descriptionController =
        TextEditingController(text: todo?.description);

    final DatabaseService _databaseService = DatabaseService();

    final TextEditingController _dateController = TextEditingController();
    Future<void> _selectDate(BuildContext context) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null) {
        setState(() {
          _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              todo == null ? "Add Task" : "Edit Task",
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                          labelText: "Title", border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    // Date Field
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: "Complete by",
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  if (todo == null) {
                    DateTime? completeByDate;
                    if (_dateController.text.isNotEmpty) {
                      completeByDate =
                          DateFormat('yyyy-MM-dd').parse(_dateController.text);
                    }

                    // Convert DateTime to Timestamp
                    Timestamp? completeByTimestamp;
                    if (completeByDate != null) {
                      completeByTimestamp = Timestamp.fromDate(completeByDate);
                    }
                    await _databaseService.addTodoTask(_titleController.text,
                        _descriptionController.text, completeByTimestamp);
                  } else {
                    await _databaseService.updateTodo(todo.id,
                        _titleController.text, _descriptionController.text);
                  }
                  Navigator.pop(context);
                },
                child: Text(todo == null ? "Add" : "Update"),
              ),
            ],
          );
        });
  }
}
