import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_first_project/core/utils.dart';
import 'package:firebase_first_project/data/appwrite_db.dart';
import 'package:firebase_first_project/data/fb_database.dart';
import 'package:firebase_first_project/data/source/functions.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appwrite/appwrite.dart';

class UpdateTask extends StatefulWidget {
  final taskId;
  final task;
  final title;
  final description;
  final color;
  const UpdateTask(
    {
      super.key,
      required this.taskId, 
      required this.task, 
      required this.title, 
      required this.description, 
      required this.color,
      }
    );

  @override
  State<UpdateTask> createState() => _UpdateTaskState();
}

class _UpdateTaskState extends State<UpdateTask> {
  final appwriteService = AppwriteService();
  final firebase = FireBaseData();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  Color _selectedColor = Colors.blue;
  String btn_txt = "SUBMIT";
  File? file;
 late Client client;
 late Storage storage;
 var inputFile;
 bool isLoading = false;
 String id = "";


   void initState() {
    getTaskValues();
    super.initState();
    storage = appwriteService.storage;

  }
  

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void getTaskValues(){
    titleController.text = widget.title;
    descriptionController.text = widget.description;
    _selectedColor = hexToColor(widget.color);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update your Task"),
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
                    inputFile = await ImageHelper.loadImage();
                    

                  setState(() {
                    file = inputFile;
                  });
                  inputFile = InputFile.fromPath(path: inputFile.path);
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
                color: _selectedColor,
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
                  setState(() {
                    isLoading = true;
                    btn_txt = "Please Wait...";
                  });
                  Future.delayed(Duration(microseconds: 900));
                  await firebase.updateTaskInDatabase(titleController, descriptionController, widget.taskId, widget.task, _selectedColor);
                  await appwriteService.updatePhoto(widget.taskId, inputFile);
                  
                  setState(() {
                    btn_txt = "Done";
                    isLoading = false;
                  });
                  id = "";
                  Future.delayed(Duration(seconds: 1), () {Navigator.pop(context);});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading?
                    
                    Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator()
                      )
                      :
                      SizedBox(),
                      
                      SizedBox(width: 12,),
                     Text(
                      btn_txt,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}