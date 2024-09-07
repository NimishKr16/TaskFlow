import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:TaskFlow/model/todo_model.dart';
import 'package:TaskFlow/services/database_services.dart';

class CompletedWidget extends StatefulWidget {
  const CompletedWidget({super.key});

  @override
  State<CompletedWidget> createState() => _CompletedWidgetState();
}

class _CompletedWidgetState extends State<CompletedWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    // TODO: Implement initState
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _databaseService.completedtodos,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Todo> todos = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index];
              final DateTime dt = todo.timeStamp.toDate();
              return Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Slidable(
                    key: ValueKey(todo.id),
                    endActionPane:
                        ActionPane(motion: DrawerMotion(), children: []),
                    startActionPane:
                        ActionPane(motion: DrawerMotion(), children: [
                      SlidableAction(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: "Remove",
                          onPressed: (context) {
                            _databaseService.deleteTodoTask(todo.id);
                          })
                    ]),
                    child: ListTile(
                      title: Text(
                        todo.title,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        todo.description,
                      ),
                      trailing: Text(
                        '${dt.day}/${dt.month}/${dt.year}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
      },
    );
  }
}
