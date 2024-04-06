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
          return _tasksListView(user.uid);
        }
      },
    );
  }

Widget _tasksListView(String uid) {
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
      Map<DateTime, Map<String, List<Todo>>> groupedTasks = _groupTasksByDayAndTime(todos);
      return ListView.builder(
        itemCount: groupedTasks.length,
        itemBuilder: (context, index) {
          DateTime day = groupedTasks.keys.elementAt(index);
          Map<String, List<Todo>> tasksByTime = groupedTasks[day]!;
          return ExpansionTile(
            title: Text(
              DateFormat('EEEE, MMM d, y').format(day),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: tasksByTime.entries.map((entry) {
              String timeSlot = entry.key;
              List<Todo> tasks = entry.value!;
              return ListTile(
                title: Text(
                  timeSlot,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: tasks.map((task) {
                    return ListTile(
                      title: Text(task.task),
                      trailing: Checkbox(
                        value: task.isDone,
                        onChanged: (value) {
                          Todo updatedTodo = task.copyWith(
                            isDone: !task.isDone,
                            updatedOn: Timestamp.now(),
                          );
                          _databaseService.updateTodo(task.id, updatedTodo); // Pass the todoId
                        },
                      ),
                      onLongPress: () {
                        _databaseService.deleteTodo(task.id); // Pass the todoId
                      },
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      );
    },
  );
}

Map<DateTime, Map<String, List<Todo>>> _groupTasksByDayAndTime(List<DocumentSnapshot> todos) {
  Map<DateTime, Map<String, List<Todo>>> groupedTasks = {};

  todos.forEach((todo) {
    Todo task = Todo.fromJson(todo.data()! as Map<String, dynamic>);
    DateTime day = DateTime(task.day.toDate().year, task.day.toDate().month, task.day.toDate().day);
    String startTimeSlot = _formatTimeSlot(task.startTime.toDate());
    String endTimeSlot = _formatTimeSlot(task.endTime.toDate());

    if (!groupedTasks.containsKey(day)) {
      groupedTasks[day] = {};
    }
    String timeSlot = '$startTimeSlot - $endTimeSlot';
    if (!groupedTasks[day]!.containsKey(timeSlot)) {
      groupedTasks[day]![timeSlot] = [];
    }
    groupedTasks[day]![timeSlot]!.add(task);
  });

  return groupedTasks;
}



String _formatTimeSlot(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}


  void _displayTextInputDialog() async {
    DateTime now = DateTime.now();
    DateTime startDate = now;
    DateTime endDate = now.add(Duration(hours: 1)); // Assuming 1 hour duration for the task

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(hintText: "Todo...."),
              ),
              SizedBox(height: 20),
              Text('Start Time:'),
              TextFormField(
                initialValue: DateFormat("h:mm a").format(startDate),
                decoration: const InputDecoration(hintText: "Start Time"),
                onTap: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(startDate),
                  );
                  if (selectedTime != null) {
                    setState(() {
                      startDate = DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              Text('End Time:'),
              TextFormField(
                initialValue: DateFormat("h:mm a").format(endDate),
                decoration: const InputDecoration(hintText: "End Time"),
                onTap: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(endDate),
                  );
                  if (selectedTime != null) {
                    setState(() {
                      endDate = DateTime(
                        endDate.year,
                        endDate.month,
                        endDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              Text('Day:'),
              TextFormField(
                initialValue: DateFormat("EEEE, MMM d, y").format(startDate),
                decoration: const InputDecoration(hintText: "Day"),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      startDate = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        startDate.hour,
                        startDate.minute,
                      );
                      endDate = startDate.add(Duration(hours: 1)); // Assuming 1 hour duration for the task
                    });
                  }
                },
              ),
            ],
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
                  day: Timestamp.fromDate(startDate), // Set the selected day
                  startTime: Timestamp.fromDate(startDate), // Set the selected start time
                  endTime: Timestamp.fromDate(endDate), // Set the selected end time
                  id: '', // Set id as empty for now, it will be updated after adding to Firestore
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
