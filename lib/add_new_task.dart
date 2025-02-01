import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_first_project/home_page.dart';
import 'package:firebase_first_project/utils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:appwrite/appwrite.dart';

class AddNewTask extends StatefulWidget {
  const AddNewTask({super.key});

  @override
  State<AddNewTask> createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  Color _selectedColor = Colors.blue;
  File? file;
 late Client client;
 late Storage storage;
 var inputFile;
 String id = "";

   void initState() {
    super.initState();

    client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1') 
      ..setProject('678a28d6001d26cfc714'); 

    storage = Storage(client);
  }
  

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

void showSnackbar(BuildContext context, String message, {Color backgroundColor = Colors.black}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating, // делает SnackBar "плавающим"
    ),
  );
}

  UploadTaskToDataBase()async{
    print("clicked");
    // if (id == "") {
    //   id = const Uuid().v4();
    //   await FirebaseFirestore.instance.collection("tasks").doc(id).set({
    //     "id": id,
    //     "title": titleController.text.trim(),
    //     "description": descriptionController.text.trim(),
    //     "date": FieldValue.serverTimestamp(),
    //     "checkBoxValue": false,
    //     "color": rgbToHex(_selectedColor),
    //     "creator": FirebaseAuth.instance.currentUser!.uid,
    //   });
    //   return ;
    // }

void showSnackbar(BuildContext context, String message, {Color backgroundColor = Colors.grey}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating, // делает SnackBar "плавающим"
    ),
  );
}


    try { 
      id = const Uuid().v4();
      await FirebaseFirestore.instance.collection("tasks").doc(id).set({
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "date": todaysDateFormatted(),
        "checkBoxValue": false,
        "color": rgbToHex(_selectedColor),
        "creator": FirebaseAuth.instance.currentUser!.uid,
        "img": id,
        "id": id,
        "isRecent": false

      });
      print(id);
      return id;
    } catch (e) {
      print(e); 
    }
  }


  Future<XFile>pickImage(ImageSource source)async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    return pickedFile!;
  }


Future loadImage() async {
  try {
    final pickedFile = await pickImage(ImageSource.gallery);

   final localFile = File(pickedFile.path);

    if (pickedFile == null) {
      throw Exception("No file selected");
    }

     inputFile = InputFile.fromPath(
      path: pickedFile.path, 
      filename: pickedFile.name, 
    );

    return localFile;

  } catch (e) {
    print("Error uploading image: $e");
  }
}

Future<void> upLoadPhoto() async {
  try {
    if (id == null || inputFile == null || storage == null) {
      print("Ошибка: не все необходимые параметры инициализированы.");
      return;
    }
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print("Нет подключения к интернету. Загрузка изображения пропущена.");
      return;
    }

    final fileId = id;
    await storage.createFile(
      bucketId: '678a2da0001c315f64f4',
      fileId: fileId,
      file: inputFile,
    );
    print("Изображение успешно загружено.");
  } catch (e) {
    print("Ошибка при загрузке изображения: $e");
  }
  
}






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        actions: [
          GestureDetector(
            onTap: () async {
              final selDate = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(
                  const Duration(days: 90),
                ),
              );
              if (selDate != null) {
                setState(() {
                  selectedDate = selDate;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('MM-d-y').format(selectedDate),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // UNCOMMENT THIS in Firebase Storage section!

              GestureDetector(
                onTap: () async {
                  final image = await loadImage();
                  setState(() {
                    file = image;
                  });
                },
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10),
                  dashPattern: const [10, 4],
                  strokeCap: StrokeCap.round,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: file != null
                        ? Image.file(file!)
                        : const Center(
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ColorPicker(
                pickersEnabled: const {
                  ColorPickerType.wheel: true,
                },
                color: Colors.blue,
                onColorChanged: (Color color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                heading: const Text('Select color'),
                subheading: const Text('Select a different shade'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async{
                  await UploadTaskToDataBase();
                  await upLoadPhoto();
                  showSnackbar(context, "New task added successfully :)");
                  Future.delayed(const Duration(seconds: 1), (){Navigator.pop(context);});
                  id = "";
                  

                  
                },
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
