
import 'package:firebase_first_project/data/source/image_picker_data_source.dart';
import 'package:firebase_first_project/domain/repositories/image_repository.dart';
import 'package:image_picker/image_picker.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImagePickerDataSource dataSource;

  ImageRepositoryImpl(this.dataSource);

  @override
  Future<XFile?> pickImage(ImageSource source) {
    return dataSource.pickImage(source);
  }
}
