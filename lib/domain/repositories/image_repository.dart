import 'package:image_picker/image_picker.dart';

abstract class ImageRepository {
  Future<XFile?> pickImage(ImageSource source);
}
