    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:firebase_auth/firebase_auth.dart';
    import 'package:firebase_first_project/core/utils.dart';
  import 'package:firebase_first_project/data/source/functions.dart';
    import 'package:flutter/material.dart';
  import 'package:hive/hive.dart';
  import 'package:uuid/uuid.dart';

    class FireBaseData {
      final FirebaseAuth _auth = FirebaseAuth.instance;

      Future<void> signOut() async {
        await _auth.signOut();
      }


      Future<void> uploadTaskToDataBase(
          String id,
          TextEditingController titleController,
          TextEditingController descriptionController,
          dynamic selectedColor) async {
        print("clicked");

        try {
          await FirebaseFirestore.instance.collection("tasks").doc(id).set({
            "title": titleController.text.trim(),
            "description": descriptionController.text.trim(),
            "date": todaysDateFormatted(),
            "checkBoxValue": false,
            "color": rgbToHex(selectedColor),
            "creator": _auth.currentUser?.uid ?? "unknown",
            "img": id,
            "id": id,
            "isRecent": false,
            "doneSum": "0/1"
          });
          print(id);
        } catch (e) {
          print("Error uploading task: $e");
        }
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


  Future<void> updateAllTasks() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection("tasks").get();

      for (var doc in snapshot.docs) {
        String doneSumStringV = doc["doneSum"];
        List<String> parts = doneSumStringV.split('/');
        int int1 = int.parse(parts[0]);
        int int2 = int.parse(parts[1]);
        await doc.reference.update({
          "date": todaysDateFormatted(),
          "checkBoxValue": false,
          "doneSum": "${int1}/${int2+1}"
        });
      }

      print("All tasks updated successfully!");
    } catch (e) {
      print("Error updating tasks: $e");
    }
  }


    // TOGGLE SECTION

      Future<void> toggleTaskCheckBox(String taskId, bool value) async {
        try {
          var SnapshotV = await FirebaseFirestore.instance.collection("tasks").doc(taskId).get();// V means Version
          String doneSumStringV = SnapshotV["doneSum"];
          List<String> parts = doneSumStringV.split('/');
          int int1 = int.parse(parts[0]);
          int int2 = int.parse(parts[1]);

          if (SnapshotV["checkBoxValue"] == true) {
            await FirebaseFirestore.instance.collection("tasks").doc(taskId).update({
              "checkBoxValue": value,
              "doneSum": "${int1-1}/$int2"
              });
            
          }else{
            await FirebaseFirestore.instance.collection("tasks").doc(taskId).update({
              "checkBoxValue": value,
              "doneSum": "${int1+1}/$int2"
              });
          }
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

    Future<void> updateTaskInDatabase(titleController, descriptionController, taskId, task, _selectedColor) async {
      try {
        await FirebaseFirestore.instance.collection("tasks").doc(taskId).update({
          "title": titleController.text.trim(),
          "description": descriptionController.text.trim(),
          "date": todaysDateFormatted(),
          "color": rgbToHex(_selectedColor),
          "img": task["img"],
        });
        print("Task updated successfully!");
      } catch (e) {
        print("Error updating task: $e");
      }
    }
  Future<List<QueryDocumentSnapshot>> fetchData(String listName) async {
    var collection = FirebaseFirestore.instance.collection(listName).where("creator", isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    var querySnapshot = await collection.get();
    return querySnapshot.docs; 
  }

  Stream<QuerySnapshot> fetchStream(String listName) {
    return FirebaseFirestore.instance.collection(listName).snapshots();
  }


  Future<void> updateHistory( oldTasks, date, uid) async {
    print(date);
    print("HERE IS UR LIST ON UPDATE HISTORY METHOD");
    print(oldTasks);
    if (oldTasks.isEmpty){
      return;
    }; 

    try {
      Map<String, dynamic> tasksMap = {};
      int count = 0;
      for (int i = 0; i < oldTasks.length; i++) {
        if (oldTasks[i]["checkBoxValue"] == true) {
          count++;
        }
        tasksMap["task$i"] = [oldTasks[i]["title"], oldTasks[i]["checkBoxValue"]];
      }

      tasksMap["creator"] = uid;
      tasksMap["date"] = date;
      
      
      

      await FirebaseFirestore.instance.collection("dates").doc(Uuid().v4()).set(tasksMap);
      print(count);
      if (count == oldTasks.length -1 &&  count >= 1) {
        print("here IS COOOOOOOOOOOOOOOOOOOOOUNT");
        print(count);
        incrementMaxDayStrike();
      }

      print("История успешно обновлена!");

    } catch (e) {
      print("Ошибка при загрузке задач: $e");
    }
  }

  Future<void> incrementMaxDayStrike() async {
    var userDocRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);

    var userData = await userDocRef.get();
    int currentStrike = (userData.data()?["maxDayStrike"] ?? 0) as int;

    await userDocRef.set({
      "maxDayStrike": currentStrike + 1
    }, SetOptions(merge: true));
  }


  Future<void> fetchDataAndUpdateHistory(List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> oldTasks, String todaysDate, String? uid, Box box) async {
    try {
      String? lastUpdatedDay = box.get("lastUpdatedDay");

      if (lastUpdatedDay == todaysDate) {
        print("Данные уже обновлялись сегодня. Пропускаем обновление.");
        return;
      }

      var user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Ошибка: пользователь не авторизован.");
        return;
      }

      var collection = FirebaseFirestore.instance.collection("tasks").where("creator", isEqualTo: user.uid);
      var querySnapshot = await collection.get();

      tasks.clear();
      tasks.addAll(querySnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>?) ?? {}));

      List<Map<String, dynamic>> newOldTasks = getAllOldTasks(oldTasks, tasks, todaysDate);

      print("THE LIST OF JUST TASKS");
      print(tasks);

      print("THE LIST OF OLD TASKS");
      print(newOldTasks);

      if (newOldTasks.isNotEmpty) {
        await updateHistory(newOldTasks, todaysDate, uid);
        await updateAllTasks();  

        box.put("lastUpdatedDay", todaysDate);
      }
    } catch (e) {
      print("Error in fetchDataAndUpdateHistory: $e");
    }
  }



  Future getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final userData = doc.data(); 
        print('User Data: $userData');
        return userData;
        
      } else {
        print('User document not found');
      }
    } else {
      print('No user logged in');
    }
  }

void checkCurrentDay(Box box) async {
  String today = todaysDateFormatted();
  print("TODAY : $today");
  
  String? currentStoredDay = box.get("currentRealDay");
  print("CURRENT STORE DATE $currentStoredDay");

  if(currentStoredDay == today){
    return;
  }else if (currentStoredDay == null || currentStoredDay != today) {
    box.put("currentRealDay", today);
    bool hasTasks = await doesUserHaveTasks();
    if (!hasTasks) {
      print("У пользователя нет задач, streak не обновляется.");
      return;
  }

  bool allTasksCompleted = await areAllTasksCompleted();

  if (allTasksCompleted) {
    await updateUserStreak(box);
  } else {
    await resetCurrentDayStrike();
  }
  }

}

Future<bool> doesUserHaveTasks() async {
  var collection = FirebaseFirestore.instance.collection("tasks")
      .where("creator", isEqualTo: FirebaseAuth.instance.currentUser?.uid);
  
  var snapshot = await collection.get();
  
  return snapshot.docs.isNotEmpty;
}



  Future<bool> areAllTasksCompleted() async {
    var collection = FirebaseFirestore.instance.collection("tasks") .where("creator", isEqualTo: FirebaseAuth.instance.currentUser?.uid);
    var snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      if (!(doc.data()["checkBoxValue"] ?? false)) {
        return false;
      }
    }
    return true; 
  }

  Future<void> updateUserStreak(Box box) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    var userData = await userRef.get();

    int currentStrike = (userData.data()?['currentDayStrike'] ?? 0) + 1;
    int maxStrike = userData.data()?['maxDayStrike'] ?? 0;
    box.put("currentDayStrikeValue", maxStrike);
    box.put("maxDayStrikeValue", maxStrike);
    

    if (userData.data()?['currentDayStrike'] != 0) {
      if (currentStrike > maxStrike) {
        maxStrike = currentStrike;
      }
    }

    await userRef.set({
      "currentDayStrike": currentStrike,
      "maxDayStrike": maxStrike,
    }, SetOptions(merge: true));

  }

  Future<void> resetCurrentDayStrike() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      "currentDayStrike": 0,
    }, SetOptions(merge: true));
  }



    }

  Future<num> getDayStrike() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    var data = doc.data();

    if (data != null) {
      return data.containsKey('currentDayStrike') ? data['currentDayStrike'] : 0;
    }
    return 0;
  }