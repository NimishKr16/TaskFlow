import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:TaskFlow/model/todo_model.dart';
import 'package:TaskFlow/services/database_services.dart';
import 'package:intl/intl.dart';

class PendingWidgets extends StatefulWidget {
  const PendingWidgets({super.key});

  @override
  State<PendingWidgets> createState() => _PendingWidgetsState();
}

class _PendingWidgetsState extends State<PendingWidgets> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;
  final DatabaseService _databaseService = DatabaseService();

  
  @override
  void initState(){
    // TODO: Implement initState
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _databaseService.todos,
      builder: (context, snapshot){
        if(snapshot.hasData){
          List<Todo> todos = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(

            ),
            itemCount: todos.length,
            itemBuilder: (context, index){
              Todo todo = todos[index];
              print(todo.completeBy);
              final DateTime? dt = todo.completeBy?.toDate();
              print(dt);
          //     String dt = completeByTimestamp != null
          // ? DateFormat('dd/MM/yyyy').format(completeByTimestamp)
          // : 'No Date Set';
              return Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Slidable(

                  key: ValueKey(todo.id),

                  endActionPane: ActionPane(motion: DrawerMotion(), children: [
                    SlidableAction(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.done,
                      label: "Done!",
                      onPressed: (context){
                      _databaseService.updateTodoStatus(todo.id, true);
                    })
                  ]),

                  startActionPane: ActionPane(motion: DrawerMotion(), children: [
                    SlidableAction(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: "Edit",
                      onPressed: (context){
                        _showTaskDialog(context, todo: todo);
                    }),
                    SlidableAction(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: "Delete",
                      onPressed: (context){
                      _databaseService.deleteTodoTask(todo.id);
                    })
                  ]),

                  child: ListTile(
                    title: Text(todo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500
                    ),),
                    subtitle: Text(todo.description,
                   ),
                   trailing: Text('${dt?.day}/${dt?.month}/${dt?.year}',
                   style: TextStyle(
                    fontWeight: FontWeight.bold,
                   ),) ,
                  )
                  
                  ),
              );
            },
          );
        }
        else{
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
      },
    );
  }
  void _showTaskDialog(BuildContext context, {Todo? todo}){
    final TextEditingController _titleController = TextEditingController(text: todo?.title);
    
    final TextEditingController _descriptionController = TextEditingController(text: todo?.description);

    final DatabaseService _databaseService = DatabaseService();
    DateTime? _completeBy;
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
        _completeBy = picked;
      });
    }
  }

    showDialog(context: context, builder: (context){
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(todo == null ? "Add Task" : "Edit Task",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black
        ),
        ),
        content: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder()
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder()
                  ),
                ),

              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, 
          child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white
            ),
            onPressed: () async {
            if(todo == null){
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
                  }
            else{
              await _databaseService.updateTodo(todo.id, _titleController.text, _descriptionController.text);
            }
            Navigator.pop(context);
          }, child: Text(todo == null ? "Add" : "Update"),
          ),

        ],
    
      );
    });

  }
}