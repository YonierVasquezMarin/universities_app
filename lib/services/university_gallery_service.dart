import 'dart:developer';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class UniversityGalleryService {
  UniversityGalleryService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<File?> pickImage() async {
    try {
      return await _pickGalleryImage();
    } catch (exception) {
      _registrarLogFailedToPickUniversityImage(exception);
      rethrow;
    }
  }

  Future<File?> _pickGalleryImage() async {
    final selectedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (selectedImage == null) {
      return null;
    }
    return _readSelectedImageFile(selectedImage);
  }

  File _readSelectedImageFile(XFile selectedImage) {
    return File(selectedImage.path);
  }

  void _registrarLogFailedToPickUniversityImage(Object exception) {
    log(
      'Failed to pick a university image from the gallery',
      name: 'UniversityGalleryService',
      error: exception,
    );
  }
}
