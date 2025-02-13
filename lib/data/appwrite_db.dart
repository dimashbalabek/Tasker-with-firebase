  import 'package:appwrite/appwrite.dart';
  import 'package:connectivity_plus/connectivity_plus.dart';

  class AppwriteService {
    late final Client _client;
    late final Storage _storage;

    AppwriteService() {
      _client = Client()
        ..setEndpoint('https://cloud.appwrite.io/v1')
        ..setProject('678a28d6001d26cfc714');

      _storage = Storage(_client);
    }

    Storage get storage => _storage;
    
  Future<void> deletePhoto(String id) async {
    try {
      if (id.isEmpty) {
        print("Ошибка: ID файла не передан.");
        return;
      }

      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print("Нет подключения к интернету. Удаление изображения пропущено.");
        return;
      }

      await _storage.deleteFile(
        bucketId: '678a2da0001c315f64f4',
        fileId: id,
      );
      print("Старое изображение успешно удалено.");
    } catch (e) {
      print("Ошибка при удалении изображения: $e");
    }
  }
  // UPDATE METHODS SECTION 
  Future<void> upLoadPhoto(id, inputFile) async {
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



  Future<void> updatePhoto(String taskId, dynamic inputFile) async {
    try {
      if (taskId.isEmpty || inputFile == null || storage == null) {
        print("Ошибка: не все необходимые параметры инициализированы.");
        return;
      }

      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print("Нет подключения к интернету. Обновление изображения пропущено.");
        return;
      }

      try {
        await storage.getFile(bucketId: '678a2da0001c315f64f4', fileId: taskId);
        
        await storage.deleteFile(
          bucketId: '678a2da0001c315f64f4',
          fileId: taskId,
        );
        print("Старое изображение успешно удалено.");
        print(taskId);
      } catch (e) {
        print("Файл не найден, создание нового.");
      }

      await storage.createFile(
        bucketId: '678a2da0001c315f64f4',
        fileId: taskId,
        file: inputFile,
      );
      print("Новое изображение успешно загружено.");
    } catch (e) {
      print("Ошибка при обновлении изображения: $e");
    }
  }


  }
