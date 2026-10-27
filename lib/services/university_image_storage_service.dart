import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class UniversityImageStorageService {
  static const String _imagesDirectoryName = 'university_images';

  Future<String> saveImage(File sourceFile) async {
    try {
      return await _copyImageIntoAppDocuments(sourceFile);
    } catch (exception) {
      _registrarLogFailedToSaveUniversityImage(exception);
      rethrow;
    }
  }

  Future<File?> findStoredImage(String fileName) async {
    try {
      return await _findExistingImage(fileName);
    } catch (exception) {
      _registrarLogFailedToFindUniversityImage(exception);
      rethrow;
    }
  }

  Future<void> deleteImage(String fileName) async {
    try {
      await _deleteStoredImage(fileName);
    } catch (exception) {
      _registrarLogFailedToDeleteUniversityImage(exception);
      rethrow;
    }
  }

  Future<String> _copyImageIntoAppDocuments(File sourceFile) async {
    final storedFileName = _buildStoredFileName(sourceFile);
    final imagesDirectory = await _createImagesDirectory();
    await _copySourceFile(sourceFile, imagesDirectory, storedFileName);
    return storedFileName;
  }

  Future<Directory> _createImagesDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final imagesDirectory = Directory(
      '${documentsDirectory.path}/$_imagesDirectoryName',
    );
    return imagesDirectory.create(recursive: true);
  }

  String _buildStoredFileName(File sourceFile) {
    final extension = _readSourceFileExtension(sourceFile);
    final uniqueName = DateTime.now().microsecondsSinceEpoch.toString();
    return '$uniqueName$extension';
  }

  String _readSourceFileExtension(File sourceFile) {
    final sourceFileName = _readSourceFileName(sourceFile);
    final extensionStart = sourceFileName.lastIndexOf('.');
    final hasExtension = extensionStart > 0;
    if (!hasExtension) {
      return '';
    }
    return sourceFileName.substring(extensionStart);
  }

  String _readSourceFileName(File sourceFile) {
    final normalizedPath = sourceFile.path.replaceAll('\\', '/');
    final segments = normalizedPath.split('/');
    return segments.last;
  }

  Future<void> _copySourceFile(
    File sourceFile,
    Directory imagesDirectory,
    String storedFileName,
  ) async {
    final destinationPath = '${imagesDirectory.path}/$storedFileName';
    await sourceFile.copy(destinationPath);
  }

  Future<File?> _findExistingImage(String fileName) async {
    final imageFile = await _readStoredImageFile(fileName);
    final imageExists = await imageFile.exists();
    if (!imageExists) {
      return null;
    }
    return imageFile;
  }

  Future<void> _deleteStoredImage(String fileName) async {
    final imageFile = await _readStoredImageFile(fileName);
    final imageExists = await imageFile.exists();
    if (!imageExists) {
      return;
    }
    await imageFile.delete();
  }

  Future<File> _readStoredImageFile(String fileName) async {
    final imagesDirectory = await _createImagesDirectory();
    return File('${imagesDirectory.path}/$fileName');
  }

  void _registrarLogFailedToSaveUniversityImage(Object exception) {
    log(
      'Failed to save the university image in the app documents directory',
      name: 'UniversityImageStorageService',
      error: exception,
    );
  }

  void _registrarLogFailedToFindUniversityImage(Object exception) {
    log(
      'Failed to find the university image in the app documents directory',
      name: 'UniversityImageStorageService',
      error: exception,
    );
  }

  void _registrarLogFailedToDeleteUniversityImage(Object exception) {
    log(
      'Failed to delete the university image from the app documents directory',
      name: 'UniversityImageStorageService',
      error: exception,
    );
  }
}
