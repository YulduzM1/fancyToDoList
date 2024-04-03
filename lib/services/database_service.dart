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

  void addTodo(Todo todo) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        todo.uid = user.uid; // Set UID of the authenticated user
        await _todosRef.add(todo);
      } else {
        throw Exception("User not authenticated");
      }
    } catch (error) {
      print('Error adding todo: $error');
    }
  }

  void updateTodo(String todoId, Todo todo) {
    _todosRef.doc(todoId).update(todo.toJson());
  }

  void deleteTodo(String todoId) {
    _todosRef.doc(todoId).delete();
  }
}
