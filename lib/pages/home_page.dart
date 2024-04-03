import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/'); // Navigate back to login screen
            },
          ),
        ],
      ),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayTextInputDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data;
        if (user == null) {
          // User is not authenticated, show login button
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/'); // Navigate to login screen
              },
              child: const Text('Login'),
            ),
          );
        } else {
          // User is authenticated, display todo list
          return _messagesListView(user.uid);
        }
      },
    );
  }

  Widget _messagesListView(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('todos')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final todos = snapshot.data?.docs ?? [];
        if (todos.isEmpty) {
          return const Center(
            child: Text("Add a todo!"),
          );
        }
        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            Todo todo = Todo.fromJson(todos[index].data()! as Map<String, dynamic>);
            String todoId = todos[index].id;
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              child: ListTile(
                tileColor: Theme.of(context).colorScheme.primaryContainer,
                title: Text(todo.task),
                subtitle: Text(
                  DateFormat("dd-MM-yyyy h:mm a").format(
                    todo.updatedOn.toDate(),
                  ),
                ),
                trailing: Checkbox(
                  value: todo.isDone,
                  onChanged: (value) {
                    Todo updatedTodo = todo.copyWith(
                      isDone: !todo.isDone,
                      updatedOn: Timestamp.now(),
                    );
                    _databaseService.updateTodo(todoId, updatedTodo);
                  },
                ),
                onLongPress: () {
                  _databaseService.deleteTodo(todoId);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _displayTextInputDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a todo'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: "Todo...."),
          ),
          actions: <Widget>[
            MaterialButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              child: const Text('Ok'),
              onPressed: () {
                Todo todo = Todo(
                  task: _textEditingController.text,
                  isDone: false,
                  createdOn: Timestamp.now(),
                  updatedOn: Timestamp.now(),
                  uid: _auth.currentUser!.uid, // Assign UID of current user
                );
                _databaseService.addTodo(todo);
                Navigator.pop(context);
                _textEditingController.clear();
              },
            ),
          ],
        );
      },
    );
  }
}
