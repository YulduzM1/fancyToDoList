import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String task;
  bool isDone;
  Timestamp createdOn;
  Timestamp updatedOn;
  String uid; // this uid is for the user's id 
  Timestamp day; // Add day field
  Timestamp startTime; // Add startTime field
  Timestamp endTime; // Add endTime field
  String id; // Add id field

  Todo({
    required this.task,
    required this.isDone,
    required this.createdOn,
    required this.updatedOn,
    required this.uid,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.id,
  });

  Todo.fromJson(Map<String, Object?> json)
      : this(
          task: json['task']! as String,
          isDone: json['isDone']! as bool,
          createdOn: json['createdOn']! as Timestamp,
          updatedOn: json['updatedOn']! as Timestamp,
          uid: json['uid']! as String,
          day: json['day']! as Timestamp,
          startTime: json['startTime']! as Timestamp,
          endTime: json['endTime']! as Timestamp,
          id: '',
        );

  Todo copyWith({
    String? task,
    bool? isDone,
    Timestamp? createdOn,
    Timestamp? updatedOn,
    String? uid,
    Timestamp? day,
    Timestamp? startTime,
    Timestamp? endTime,
    String? id,
  }) {
    return Todo(
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
      createdOn: createdOn ?? this.createdOn,
      updatedOn: updatedOn ?? this.updatedOn,
      uid: uid ?? this.uid,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      id: id ?? this.id,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'task': task,
      'isDone': isDone,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
      'uid': uid,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
