import 'package:firebase_first_project/domain/repositories/image_repository.dart';
import 'package:image_picker/image_picker.dart';

class PickImageUseCase {
  final ImageRepository repository;

  PickImageUseCase(this.repository);

  Future<XFile?> call(ImageSource source) {
    return repository.pickImage(source);
  }
}
