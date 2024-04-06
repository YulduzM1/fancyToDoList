import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/todo.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String TODO_COLLECTON_REF = "todos";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late final CollectionReference _todosRef;

  DatabaseService() {
    _todosRef = _firestore.collection(TODO_COLLECTON_REF).withConverter<Todo>(
      fromFirestore: (snapshots, _) => Todo.fromJson(
        snapshots.data()!,
      ),
      toFirestore: (todo, _) => todo.toJson(),
    );
  }

  Stream<QuerySnapshot> getTodos() {
    return _todosRef.snapshots();
  }
Future<void> addTodo(Todo todo) async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      todo.uid = user.uid; // Set UID of the authenticated user
      await _todosRef.add(todo); // Pass Todo object directly to Firestore
    } catch (error) {
      print('Error adding todo: $error');
      throw Exception('Error adding todo: $error');
    }
  } else {
    throw Exception("User not authenticated");
  }
}




  void updateTodo(String todoId, Todo todo) {
    _todosRef.doc(todoId).update(todo.toJson());
  }

  void deleteTodo(String todoId) {
    _todosRef.doc(todoId).delete();
  }
}
