import 'dart:io';
import 'dart:ui';

import 'package:image_picker/image_picker.dart';

Color strengthenColor(Color color, double factor) {
  int r = (color.red * factor).clamp(0, 255).toInt();
  int g = (color.green * factor).clamp(0, 255).toInt();
  int b = (color.blue * factor).clamp(0, 255).toInt();
  return Color.fromARGB(color.alpha, r, g, b);
}

String rgbToHex(Color color) {
  return '${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}

Color hexToColor(String hex) {
  return Color(int.parse(hex, radix: 16) + 0xFF000000);
}

Future<File?> selectImage() async {
  final imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
  if (file != null) {
    return File(file.path);
  }
  return null;
}

List<String> currentWeekDates() {
  DateTime today = DateTime.now();
  int currentWeekday = today.weekday; // 1 (Monday) - 7 (Sunday)

  DateTime startOfWeek = today.subtract(Duration(days: currentWeekday - 1));

  List<String> weekDates = List.generate(7, (index) {
    DateTime date = startOfWeek.add(Duration(days: index));
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return "$year$month$day";
  });

  print(weekDates);

  return weekDates;
}

List<String> currentWeekDatesWithTime() {
  DateTime today = DateTime.now();
  int currentWeekday = today.weekday; // 1 (Monday) - 7 (Sunday)

  DateTime startOfWeek = today.subtract(Duration(days: currentWeekday - 1));

  List<String> weekDates = List.generate(7, (index) {
    DateTime date = startOfWeek.add(Duration(days: index));
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    return "$year$month$day" + "_$hour$minute";
  });

  print(weekDates);

  return weekDates;
}


String todaysDateFormatted() {
  // today
  var dateTimeObject = DateTime.now();

  // year in the format yyyy
  String year = dateTimeObject.year.toString();

  // month in the format mm
  String month = dateTimeObject.month.toString();
  if (month.length == 1) {
    month = "0" + month;
  }

  // day in the format dd
  String day = dateTimeObject.day.toString();
  if (day.length == 1) {
    day = "0" + day;
  }

  // hour in the format hh
  String hour = dateTimeObject.hour.toString();
  if (hour.length == 1) {
    hour = "0" + hour;
  }

  // minute in the format mm
  String minute = dateTimeObject.minute.toString();
  if (minute.length == 1) {
    minute = "0" + minute;
  }

  // final format
  String yyyymmdd = year + month + day ;

  return yyyymmdd;
}


// String todaysDateFormatted() {
//   // today
//   var dateTimeObject = DateTime.now();

//   // year in the format yyyy
//   String year = dateTimeObject.year.toString();

//   // month in the format mm
//   String month = dateTimeObject.month.toString();
//   if (month.length == 1) {
//     month = "0" + month;
//   }

//   // day in the format dd
//   String day = dateTimeObject.day.toString();
//   if (day.length == 1) {
//     day = "0" + day;
//   }

//   // final format
//   String yyyymmdd = year + month + day;

//   return yyyymmdd;
// }
