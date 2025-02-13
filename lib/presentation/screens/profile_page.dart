import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_first_project/data/appwrite_db.dart';
import 'package:firebase_first_project/data/fb_database.dart';
import 'package:firebase_first_project/data/source/functions.dart';
import 'package:firebase_first_project/presentation/widgets/circular_progress_bar.dart';
import 'package:firebase_first_project/presentation/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final firebase = FireBaseData();
  final appwriteService = AppwriteService();
  final user = FirebaseAuth.instance.currentUser;
  var inputFile;
  File? file;
 late Client client;
 late Storage storage;
 bool isLoading = false;
 var box = Hive.box('myBox');
 String id = "";
 List<double> weekData = List.generate(7, (index) => 0);
@override
void initState() {
  super.initState();
  storage = appwriteService.storage;
  weekData = box.get("weekData");
  print(weekData);

}

// БОКС УБЕРИ НАФИГ ТВОЯ КОНЦЕПЦИЯ ПРОВАЛИЛАСЬ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FutureBuilder<dynamic>(
                future: firebase.getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Ошибка загрузки данных: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('Нет данных пользователя'));
                  }

                  var userProfileData = snapshot.data;

                  return Card(
                    
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                            GestureDetector(
                              onTap: () async{
                            
                                inputFile = await ImageHelper.loadImage();
                                if (inputFile != null) {
                                  setState(() {  
                                    file = inputFile;
                                    inputFile = InputFile.fromPath(path: inputFile.path);
                                    id = Uuid().v4();
                                  });
                                  SnackbarHelper.showSnackbar(context, "Your Photo will be updated soon :)");
                      
                                  
                                    await appwriteService.updatePhoto(user!.uid, inputFile);
                      
                                  } else {
                                    print("Файл не был выбран или произошла ошибка при загрузке.");
                                    }
                              },
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage('https://cloud.appwrite.io/v1/storage/buckets/678a2da0001c315f64f4/files/${user!.uid}/view?project=678a28d6001d26cfc714&mode=admin'),
                              ),
                            )
                          ],
                          ),
                          const SizedBox(width: 14),
                          Text(
                            userProfileData["userName"] ?? 'Неизвестный',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.exit_to_app),
                                onPressed: () {
                                  firebase.signOut();
                                },
                              ),
                              const Text("Sign Out")
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<dynamic>(
                  future: FirebaseFirestore.instance.collection("tasks").where("creator", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Ошибка загрузки задач: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text('Нет данных о задачах'));
                    }

                    var tasksData = snapshot.data.docs;

                    return ListView(
                      children: [
                        buildCard(
                          title: 'Weekly Stats',
                          child: Center(
                            child: CircularProgressBar(
                              progress: double.parse(calculateProgress(weekData)) / 100, 
                              ),
                          ),
                          ),
                          FutureBuilder(
                            future: firebase.getUserData(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  height: 50,
                                  width: 50,
                                  child: const CircularProgressIndicator()
                                  ); 
                              }

                              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                return const Text('Ошибка загрузки'); 
                              }

                              var userProfileData = snapshot.data ;
                              return buildCard(
                                title: "Max Days in a Row",
                                child: Center(
                                  child: Column(
                                    children: [
                                      Image.asset("assets/the day2.png", width: 40,),
                                      SizedBox(height: 10,),
                                      Text(
                                        "${userProfileData["maxDayStrike"]}" ?? 'Неизвестный', 
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                          ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        buildCard(
                          title: 'My Activities',
                          child: tasksData.isEmpty?
                          Center(child: 
                           const Text(
                            "There is no Activity here yet",
                            style: TextStyle(
                              color: Colors.grey
                            ),
                          )
                          )
                          :
                          Column(
                            children: tasksData.map<Widget>((doc) {
                              var task = doc.data() as Map<String, dynamic>; 
                              return  buildActivity(
                                task['title'] ?? 'Без названия',
                                '${task['doneSum']}',
                                );
                              }).toList(),
                          ),
                        ),

                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
