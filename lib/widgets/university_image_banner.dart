import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:universities_app/models/university.dart';
import 'package:universities_app/services/university_image_storage_service.dart';

class UniversityImageBanner extends StatefulWidget {
  const UniversityImageBanner({
    super.key,
    required this.university,
    this.imageFile,
    this.loadsStoredImage = true,
    this.usesCompactIdentity = false,
  });

  final University university;
  final File? imageFile;
  final bool loadsStoredImage;
  final bool usesCompactIdentity;

  @override
  State<UniversityImageBanner> createState() => _UniversityImageBannerState();
}

class _UniversityImageBannerState extends State<UniversityImageBanner> {
  static const double _compactIdentityTopPadding = 12;
  static const double _compactIconSize = 24;
  static const double _compactIconGap = 4;
  static const double _iconSize = 32;
  static const double _iconGap = 8;

  final UniversityImageStorageService _imageStorageService =
      UniversityImageStorageService();

  File? _storedImage;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadStoredImageWhenNeeded();
  }

  @override
  void didUpdateWidget(UniversityImageBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncStoredImage(oldWidget);
  }

  void _loadStoredImageWhenNeeded() {
    if (_shouldLoadStoredImage()) {
      unawaited(_loadStoredImage());
    }
  }

  void _syncStoredImage(UniversityImageBanner oldWidget) {
    if (!_storedImageInputsChanged(oldWidget)) {
      return;
    }
    if (_shouldLoadStoredImage()) {
      unawaited(_loadStoredImage());
      return;
    }
    _clearStoredImage();
  }

  bool _storedImageInputsChanged(UniversityImageBanner oldWidget) {
    final fileNameChanged = _imageFileNameChanged(oldWidget);
    final loadFlagChanged = widget.loadsStoredImage != oldWidget.loadsStoredImage;
    final providedImageChanged = _providedImageChanged(oldWidget);
    return fileNameChanged || loadFlagChanged || providedImageChanged;
  }

  bool _imageFileNameChanged(UniversityImageBanner oldWidget) {
    final fileNameChanged =
        widget.university.imageFileName != oldWidget.university.imageFileName;
    return fileNameChanged;
  }

  bool _providedImageChanged(UniversityImageBanner oldWidget) {
    final providedImageChanged =
        widget.imageFile?.path != oldWidget.imageFile?.path;
    return providedImageChanged;
  }

  bool _shouldLoadStoredImage() {
    if (!_loadsStoredImage()) {
      return false;
    }
    if (_hasProvidedImage()) {
      return false;
    }
    return _hasImageFileName();
  }

  bool _loadsStoredImage() {
    return widget.loadsStoredImage;
  }

  bool _hasProvidedImage() {
    return widget.imageFile != null;
  }

  bool _hasImageFileName() {
    return _readImageFileName() != null;
  }

  Future<void> _loadStoredImage() async {
    final loadGeneration = _beginStoredImageLoad();
    final fileName = _readImageFileName();
    if (fileName == null) {
      _showStoredImage(loadGeneration, null);
      return;
    }
    try {
      final image = await _imageStorageService.findStoredImage(fileName);
      _showStoredImage(loadGeneration, image);
    } catch (_) {
      _showStoredImage(loadGeneration, null);
    }
  }

  int _beginStoredImageLoad() {
    _loadGeneration += 1;
    return _loadGeneration;
  }

  void _clearStoredImage() {
    final loadGeneration = _beginStoredImageLoad();
    _showStoredImage(loadGeneration, null);
  }

  void _showStoredImage(int loadGeneration, File? image) {
    if (!_loadIsCurrent(loadGeneration)) {
      return;
    }
    setState(() {
      _storedImage = image;
    });
  }

  bool _loadIsCurrent(int loadGeneration) {
    final loadIsCurrent = loadGeneration == _loadGeneration;
    final widgetIsMounted = mounted;
    return loadIsCurrent && widgetIsMounted;
  }

  String? _readImageFileName() {
    final fileName = widget.university.imageFileName?.trim() ?? '';
    if (fileName.isEmpty) {
      return null;
    }
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: _buildBanner(context));
  }

  Widget _buildBanner(BuildContext context) {
    final imageFile = _readVisibleImageFile();
    if (imageFile == null) {
      return _buildPlaceholder(context);
    }
    return _buildImage(context, imageFile);
  }

  File? _readVisibleImageFile() {
    final providedImage = widget.imageFile;
    if (providedImage != null) {
      return providedImage;
    }
    if (!_loadsStoredImage()) {
      return null;
    }
    return _storedImage;
  }

  Widget _buildImage(BuildContext context, File imageFile) {
    return Image.file(
      imageFile,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: _buildBrokenImage,
    );
  }

  Widget _buildBrokenImage(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [_buildGradient(context), _buildIdentity(context)],
    );
  }

  Widget _buildGradient(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _buildGradientColors(context),
        ),
      ),
    );
  }

  List<Color> _buildGradientColors(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final softenedPrimary = Color.lerp(primary, Colors.white, 0.18) ?? primary;
    return [primary, softenedPrimary];
  }

  Widget _buildIdentity(BuildContext context) {
    if (_usesCompactIdentity()) {
      return _buildCompactIdentity(context);
    }
    return Center(child: _buildIdentityContent(context));
  }

  bool _usesCompactIdentity() {
    return widget.usesCompactIdentity;
  }

  Widget _buildCompactIdentity(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: _compactIdentityTopPadding),
        child: _buildIdentityContent(
          context,
          iconSize: _compactIconSize,
          gap: _compactIconGap,
        ),
      ),
    );
  }

  Widget _buildIdentityContent(
    BuildContext context, {
    double iconSize = _iconSize,
    double gap = _iconGap,
  }) {
    final foregroundColor = Theme.of(context).colorScheme.onPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.school_outlined, color: foregroundColor, size: iconSize),
        SizedBox(height: gap),
        Text(_buildInitials(), style: _buildInitialsTextStyle(context)),
      ],
    );
  }

  TextStyle _buildInitialsTextStyle(BuildContext context) {
    final foregroundColor = Theme.of(context).colorScheme.onPrimary;
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    return (titleStyle ?? const TextStyle()).copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w600,
    );
  }

  String _buildInitials() {
    final words = _readNameWords();
    final initials = words.take(2).map(_readWordInitial);
    return initials.join().toUpperCase();
  }

  List<String> _readNameWords() {
    final words = widget.university.name.split(RegExp(r'\s+'));
    return words.where(_wordHasContent).toList();
  }

  bool _wordHasContent(String word) {
    final hasContent = word.trim().isNotEmpty;
    return hasContent;
  }

  String _readWordInitial(String word) {
    return word.substring(0, 1);
  }
}
