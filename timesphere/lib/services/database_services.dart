import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timesphere/model/todo_model.dart';

class DatabaseService {
  final CollectionReference todoCollection = FirebaseFirestore.instance.collection("todos");
  User? user = FirebaseAuth.instance.currentUser;
  
  // Add Todo Task
  Future<DocumentReference> addTodoTask(String title, String description) async{
    return await todoCollection.add({
      'uid' : user!.uid,
      'title' : title,
      'description': description,
      'completed' :  false,
      'createdAt' : FieldValue.serverTimestamp(),
    });
  }

  // Update Todo Task
  Future<void> updateTodo(String id, String title, String description ) async{
    final updateTodoCol = FirebaseFirestore.instance.collection('todos').doc(id);
    return await updateTodoCol.update({
      'title' : title,
      'description' : description,

    });

  }

  // Update Todo Status
  Future<void> updateTodoStatus(String id, bool completed ) async{
    return await todoCollection.doc(id).update({'completed' : completed})
  }

  // Delete Todo Task
  Future<void> deleteTodoTask(String id) async{
    return await todoCollection.doc(id).delete();
  }

  // Get pending tasks
  Stream<List<Todo>> get todos{
    return todoCollection.where('uid', isEqualTo: user!.uid).where('completed',isEqualTo: false).snapshots().map(_todoListFromSnapshot);
  }

  // Get completed tasks
  Stream<List<Todo>> get completedtodos{
    return todoCollection.where('uid', isEqualTo: user!.uid).where('completed',isEqualTo: true).snapshots().map(_todoListFromSnapshot);
  }

  List<Todo> _todoListFromSnapshot (QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Todo(id: doc.id, title: doc['title'] ?? '' , description: doc['description'] ?? '', completed: doc['completed'] ?? '', timeStamp: doc['createdAt'] ?? '')
    }).toList();
  }
  }
