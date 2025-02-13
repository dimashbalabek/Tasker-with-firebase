import 'package:hive/hive.dart';

class HiveService {
  static final _box = Hive.box('myBox');

  static Future<List<double>> loadWeekData() async {
    List<dynamic>? storedData = _box.get('weekData');

    if (storedData != null && storedData is List<double>) {
      return storedData;
    } else {
      return List.generate(7, (index) => 0);
    }
  }

// Hive functions and methods
  static Future<void> saveWeekData(List<double> data) async {
    await _box.put('weekData', data);
    print(_box.get("weekData"));
  }
}
