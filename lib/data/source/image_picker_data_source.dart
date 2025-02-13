import 'package:image_picker/image_picker.dart';

class ImagePickerDataSource {
  final ImagePicker picker;

  ImagePickerDataSource({required this.picker});

  Future<XFile?> pickImage(ImageSource source) async {
    return await picker.pickImage(source: source);
  }
}
