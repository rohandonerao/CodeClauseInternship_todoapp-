// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/authscreen.dart';

class HomeScreen extends StatefulWidget {
  static const String KEYLOGIN = 'login';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController taskController = TextEditingController();
  List<String> tasks = [];

  String get userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _tasksCollection => FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('tasks');

  void loadTasks() async {
    try {
      final snapshot = await _tasksCollection.get();
      setState(() {
        tasks = snapshot.docs
            .map(
                (doc) => (doc.data() as Map<String, dynamic>)['task'] as String)
            .toList();
      });
    } catch (e) {
      print('Error loading tasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load tasks")),
      );
    }
  }

  void addTask() async {
    if (_auth.currentUser == null) {
      print("Error: No authenticated user.");
      return;
    }

    print("Saving task to path: users/$userId/tasks");

    if (taskController.text.trim().isNotEmpty) {
      try {
        await _tasksCollection.add({'task': taskController.text.trim()});
        print("Task added successfully.");
        loadTasks();
        taskController.clear();
      } catch (e) {
        print('Error adding task: $e');
      }
    } else {
      print("Error: Task cannot be empty.");
    }
  }

  void deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
      loadTasks();
    } catch (e) {
      print('Error deleting task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete task")),
      );
    }
  }

  void logout(BuildContext context) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool(HomeScreen.KEYLOGIN, false);
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => login()),
    );
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do List"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      labelText: "New Task",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addTask,
                  icon: Icon(Icons.add, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _tasksCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final tasks = snapshot.data!.docs;
                return tasks.isEmpty
                    ? Center(
                        child: Text(
                          "No tasks available",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task =
                              tasks[index].data() as Map<String, dynamic>;
                          final taskId = tasks[index].id;
                          return Card(
                            margin: EdgeInsets.all(8),
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                task['task'],
                                style: TextStyle(fontSize: 18),
                              ),
                              trailing: IconButton(
                                onPressed: () => deleteTask(taskId),
                                icon: Icon(Icons.delete),
                                color: Colors.redAccent,
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
