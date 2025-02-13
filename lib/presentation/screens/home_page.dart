  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:firebase_first_project/data/appwrite_db.dart';
  import 'package:firebase_first_project/data/fb_database.dart';
  import 'package:firebase_first_project/presentation/screens/add_new_task.dart';
  import 'package:firebase_first_project/presentation/screens/update_task.dart';
  import 'package:firebase_first_project/core/utils.dart';
  import 'package:firebase_first_project/presentation/widgets/task_card.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_slidable/flutter_slidable.dart';
  import 'package:hive/hive.dart';

    class MyHomePage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const MyHomePage(),
      );
      const MyHomePage({super.key});

      @override
      State<MyHomePage> createState() => _MyHomePageState();
    }
  class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
    final appwriteService = AppwriteService();
    final firebase = FireBaseData();
    var box = Hive.box('myBox');
    bool showRecent = false;
    bool isLoading = false;
    String todaysDate = todaysDateFormatted();
    num dayStrike = 0;
    Map<String, AnimationController> animationControllers = {};
    List<Map<String, dynamic>> oldTasks = [];
    List<Map<String, dynamic>> tasks = [];
  String? user = FirebaseAuth.instance.currentUser?.uid;
  

    @override
@override
void initState() {
  super.initState();
  box.get("currentDayStrikeValue") == null? box.put("currentDayStrikeValue", 0): print("");
  firebase.checkCurrentDay(box);
  dayStrike = box.get("currentDayStrikeValue");
  
  if (user != null) {
    firebase.fetchDataAndUpdateHistory(tasks, oldTasks, todaysDate, user, box);
  } else {
    print("Ошибка: пользователь не авторизован.");
  }  

}



    @override
    void dispose() {
      for (var controller in animationControllers.values) {
        controller.dispose();
      }
      super.dispose();
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
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('My Tasks'),
                SizedBox(width: 15,),
                Image.asset("assets/the day2.png", width: 18,),
                SizedBox(width: 4,),
FutureBuilder(
  future: firebase.getUserData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator(); 
    }

    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
      return const Text('Ошибка загрузки'); 
    }

    var userProfileData = snapshot.data ;
    return Text(
      "${userProfileData["currentDayStrike"]}" ?? 'Неизвестный', 
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  },
),
              ],
            ),
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
          body: 
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : 
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("tasks")
                      .where("creator", isEqualTo: user)
                      .where("isRecent", isEqualTo: showRecent)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No data here :/"));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final task = snapshot.data!.docs[index].data();
                        final taskId = snapshot.data!.docs[index].id;
                        print("AAAAAAAAAAAAAAAAAAAA THIS IS IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIID");
                        print(taskId);
                        final recentValue = task["isRecent"];

                        animationControllers.putIfAbsent(
                          taskId,
                          () => AnimationController(
                            vsync: this,
                            duration: const Duration(milliseconds: 300),
                          ),
                        );

                        return AnimatedBuilder(
                          animation: animationControllers[taskId]!,
                          builder: (context, child) {
                            double value = animationControllers[taskId]!.value * 20;
                            return Transform.translate(
                              offset: recentValue ? Offset(-value, 0) : Offset(value, 0),
                              child: Opacity(
                                opacity: (20 - value) / 20,
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              
                              SizedBox(height: 12,),
                              Slidable( 
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        animationControllers[taskId]!.forward().then((_) {
                                          firebase.deleteTaskFromDatabase(taskId);
                                          appwriteService.deletePhoto(taskId);
                                        });
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
                                            builder: (context) => UpdateTask(
                                              taskId: taskId,
                                              task: task,
                                              title: task['title'],
                                              description: task["description"],
                                              color: task["color"],
                                            ),
                                          ),
                                        );
                                      },
                                      backgroundColor: Colors.grey,
                                      icon: Icons.edit,
                                      label: "Edit",
                                    ),
                                  ],
                                ),
                                child: TaskCard(
                                  isRecent: recentValue,
                                  onStarTapped: () {
                                    animationControllers[taskId]!.forward().then((_) {
                                      firebase.toggleTaskStar(task["id"], !recentValue);
                                      Future.delayed(const Duration(milliseconds: 500), () {
                                        animationControllers[taskId]!.reset();
                                      });
                                    });
                                  },
                                  onChanged: (value) {
                                    firebase.toggleTaskCheckBox(task["id"], value!);
                                  },
                                  habitCompleted: task["checkBoxValue"],
                                  color: hexToColor(task["color"]),
                                  headerText: task['title'],
                                  descriptionText: task["description"],
                                  scheduledDate: task["color"],
                                  img:
                                      "https://cloud.appwrite.io/v1/storage/buckets/678a2da0001c315f64f4/files/${task["id"]}/view?project=678a28d6001d26cfc714&mode=admin",
                                ),
                              ),

                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      );
    }
  }