import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String task;
  bool isDone;
  Timestamp createdOn;
  Timestamp updatedOn;
  String uid; // Add uid field

  Todo({
    required this.task,
    required this.isDone,
    required this.createdOn,
    required this.updatedOn,
    required this.uid, // Initialize the userId field
  });

  Todo.fromJson(Map<String, Object?> json)
      : this(
          task: json['task']! as String,
          isDone: json['isDone']! as bool,
          createdOn: json['createdOn']! as Timestamp,
          updatedOn: json['updatedOn']! as Timestamp,
          uid: json['uid']! as String, // Assign the value of userId from JSON
        );

  Todo copyWith({
    String? task,
    bool? isDone,
    Timestamp? createdOn,
    Timestamp? updatedOn,
    String? uid, // Include userId in copyWith method
  }) {
    return Todo(
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
      createdOn: createdOn ?? this.createdOn,
      updatedOn: updatedOn ?? this.updatedOn,
      uid: uid ?? this.uid, // Assign userId from the parameter or keep the existing one
    );
  }

  Map<String, Object?> toJson() {
    return {
      'task': task,
      'isDone': isDone,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
      'uid': uid, // Include userId in the JSON representation
    };
  }
}
