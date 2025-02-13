import 'package:firebase_first_project/data/fb_database.dart';
import 'package:firebase_first_project/data/source/functions.dart';
import 'package:firebase_first_project/data/source/hive_service.dart';
import 'package:firebase_first_project/presentation/widgets/bar_graph.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final firebase = FireBaseData();
  List<double> currentWeekDatas = List.generate(7, (index) => 0); 
  late Future<List<QueryDocumentSnapshot>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<List<QueryDocumentSnapshot>> fetchData() async {
    List<QueryDocumentSnapshot> documents = await firebase.fetchData("dates");

    updateGraph(documents);
    return documents;
  }
void updateGraph(List<QueryDocumentSnapshot> documents) {
  List<double> newWeekData = List.generate(7, (index) => 0);
  List<int> totalTasksPerDay = List.generate(7, (index) => 0);

  for (var doc in documents) {
    final data = doc.data() as Map<String, dynamic>;

    if (!data.containsKey("date") || data["date"] is! String) {
      debugPrint("Skipping document without a valid date field: ${doc.id}");
      continue;
    }

    DateTime? date;
    try {
      date = DateTime.parse(data["date"]);
    } catch (e) {
      debugPrint("Invalid date format in document ${doc.id}: ${data["date"]}");
      continue;
    }

    int weekdayIndex = date.weekday - 1;

    data.forEach((key, value) {
      if (key.startsWith("task") && value is List) {
        totalTasksPerDay[weekdayIndex] += 1;
        if (value[1] == true) {
          newWeekData[weekdayIndex] += 1;
        }
      }
    });
  }

  for (int i = 0; i < 7; i++) {
    if (totalTasksPerDay[i] > 0) {
      newWeekData[i] = (newWeekData[i] / totalTasksPerDay[i]) * 100;
    }
  }

  setState(() {
    currentWeekDatas = newWeekData;
  });

  HiveService.saveWeekData(newWeekData); 
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: MyBarGraph(weeklySummary: currentWeekDatas),
            ),
            Expanded(
              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print("${snapshot.error}");
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No Data found'));
                  } else {
                    final documents = snapshot.data!;



                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        final data = doc.data() as Map<String, dynamic>;

                        List<Map<String, dynamic>> tasks = [];
                        data.forEach((key, value) {
                          if (key.startsWith("task") && value is List) {
                            tasks.add({"title": value[0], "completed": value[1]});
                          }
                        });

                        return ExpansionTile(
                          title: Text("Date: ${doc['date']}"),
                          children: tasks.map((task) {
                            return ListTile(
                              title: Text(task["title"] ?? "No Title"),
                              subtitle: Text(task["completed"] ? "Completed" : "Pending"),
                              leading: Icon(
                                task["completed"] ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: task["completed"] ? Colors.green : Colors.grey,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
