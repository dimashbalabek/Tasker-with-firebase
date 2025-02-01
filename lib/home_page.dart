import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_first_project/add_new_task.dart';
import 'package:firebase_first_project/update_task.dart';
import 'package:firebase_first_project/utils.dart';
import 'package:firebase_first_project/widgets/task_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showRecent = false;
  late Storage storage;
  late Client client;
  File? files;
  var inputFile;
  bool isLoading = false;

  Future upload() async {
    try {
      client = Client()
        ..setEndpoint('https://cloud.appwrite.io/v1')
        ..setProject('678a28d6001d26cfc714');
      storage = Storage(client);
    } catch (e) {
      print("Error initializing Appwrite client: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Initialization error: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    updateData();
    upload();
  }

  deleteTaskFromDatabase(String id) async {
    try {
      if (id.isEmpty) {
        print("ID не передан.");
        return;
      }

      await FirebaseFirestore.instance.collection("tasks").doc(id).delete();
      print("Задача с ID $id успешно удалена.");
    } catch (e) {
      print("Ошибка при удалении задачи: $e");
    }
  }

  Future<void> updateData() async {
    try {
      await FirebaseFirestore.instance.collection("tasks").doc().update({
        "date": todaysDateFormatted(),
      });
      print("Dates are updated successfully!");
    } catch (e) {
      print("Error updating task: $e");
    }
  }

  Future<void> deletePhoto(String id) async {
    try {
      if (id.isEmpty || storage == null) {
        print("Ошибка: не все необходимые параметры инициализированы.");
        return;
      }

      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print("Нет подключения к интернету. Удаление изображения пропущено.");
        return;
      }

      await storage.deleteFile(
        bucketId: '678a2da0001c315f64f4',
        fileId: id,
      );
      print("Старое изображение успешно удалено.");
    } catch (e) {
      print("Ошибка при удалении изображения: $e");
    }
  }

  Future<void> toggleTaskCheckBox(String taskId, bool value) async {
    try {
      await FirebaseFirestore.instance.collection("tasks").doc(taskId).update({
        "checkBoxValue": value,
      });
      print("Checkbox updated for task $taskId");
    } catch (e) {
      print("Error updating checkbox: $e");
    }
  }

  Future<void> toggleTaskStar(String taskId, bool value) async {
    try {
      await FirebaseFirestore.instance.collection("tasks").doc(taskId).update({
        "isRecent": value,
      });
      print("Star updated for task $taskId");
    } catch (e) {
      print("Error updating star status: $e");
    }
  }

  Future<void> loadData(bool isImportant) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      showRecent = isImportant;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Tasks'),
          bottom: TabBar(
            onTap: (value) {
              loadData(value == 1);
            },
            tabs: const [
              Tab(text: 'General'),
              Tab(text: 'Important'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddNewTask(),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.add),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("tasks")
                          .where("creator",
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .where("isRecent", isEqualTo: showRecent)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No data here :/"),
                          );
                        }

                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final task = snapshot.data!.docs[index].data();
                              final taskId =
                                  snapshot.data!.docs[index].id;
                              final recentValue = task["isRecent"];

                              return Column(
                                children: [
                                  Slidable(
                                    endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            deleteTaskFromDatabase(taskId);
                                            deletePhoto(taskId);
                                          },
                                          backgroundColor: Colors.red,
                                          icon: Icons.delete,
                                          label: "Delete",
                                        ),
                                        SlidableAction(
                                          onPressed: (context) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateTask(
                                                  taskId: taskId,
                                                  task: task,
                                                  title: task['title'],
                                                  description:
                                                      task["description"],
                                                  color: task["color"],
                                                ),
                                              ),
                                            );
                                          },
                                          backgroundColor: const Color.fromARGB(
                                              255, 191, 190, 190),
                                          icon: Icons.edit,
                                          label: "Edit",
                                        ),
                                      ],
                                    ),
                                    child: task.containsKey("img") &&task["img"] != null && task["img"].isNotEmpty? 
                                  TaskCard(
                                    isRecent: recentValue,
                                    onStarTapped: () {
                                      toggleTaskStar(task["id"], !recentValue);
                                    },
                                    onChanged: (value) {
                                      toggleTaskCheckBox(task["id"], value!);
                                    },
                                    habitCompleted: task["checkBoxValue"],
                                    color: hexToColor(task["color"]),
                                    headerText: task['title'],
                                    descriptionText: task["description"],
                                    scheduledDate: task["color"],
                                    img:  "https://cloud.appwrite.io/v1/storage/buckets/678a2da0001c315f64f4/files/${task["img"]}/view?project=678a28d6001d26cfc714&project=678a28d6001d26cfc714&mode=admin"
                          
                                  )
                                  :
                                  TaskCard(
                                    isRecent: recentValue,
                                    onStarTapped: () {
                                      toggleTaskStar(task["id"], !recentValue);
                                    },
                                    onChanged: (value) {
                                      toggleTaskCheckBox(task["id"], value!);
                                    },
                                    habitCompleted: task["checkBoxValue"],
                                    color: hexToColor(task["color"]),
                                    headerText: task['title'],
                                    descriptionText: task["description"],
                                    scheduledDate: task["color"],
                          
                                  )
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
