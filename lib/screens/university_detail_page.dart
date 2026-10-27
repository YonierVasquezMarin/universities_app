import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universities_app/models/university.dart';
import 'package:universities_app/services/university_gallery_service.dart';
import 'package:universities_app/services/university_image_storage_service.dart';
import 'package:universities_app/widgets/app_bar_component.dart';
import 'package:universities_app/widgets/university_image_banner.dart';

class UniversityDetailPage extends StatefulWidget {
  const UniversityDetailPage({super.key, required this.university});

  final University university;

  @override
  State<UniversityDetailPage> createState() => _UniversityDetailPageState();
}

class _UniversityDetailPageState extends State<UniversityDetailPage> {
  static const double _maxContentWidth = 480;
  static const double _horizontalPadding = 16;
  static const double _headerHeight = 220;
  static const double _cardRadius = 20;
  static const double _sectionGap = 20;
  static const double _blockGap = 12;
  static const double _rowGap = 8;
  static const double _valueGap = 4;
  static const double _saveButtonTopPadding = 4;
  static const double _actionGap = 8;
  static const double _actionInset = 12;
  static const double _iconSize = 18;
  static const double _iconGap = 8;
  static const double _saveIndicatorSize = 20;
  static const int _maximumStudentCount = 9999999;
  static const int _maximumStudentDigits = 7;
  static const String _pageTitle = 'Detalle';
  static const String _domainSectionTitle = 'Dominios';
  static const String _webPageSectionTitle = 'Sitios web';
  static const String _emptyDomainLabel = 'Sin dominio';
  static const String _emptyWebPageLabel = 'Sin sitio web';
  static const String _studentCountLabel = 'Cantidad de estudiantes';
  static const String _studentCountHelper =
      'Solo números enteros mayores que cero. Déjalo vacío para quitar el registro.';
  static const String _invalidStudentCountMessage = 'Ingresa solo números enteros';
  static const String _nonPositiveStudentCountMessage =
      'La cantidad debe ser mayor que cero';
  static const String _studentCountLimitMessage =
      'La cantidad no puede superar 9.999.999';
  static const String _saveStudentCountTooltip =
      'Guardar cantidad de estudiantes';
  static const String _galleryFailureMessage = 'No fue posible abrir la galería';
  static const String _saveFailureMessage = 'No fue posible guardar los datos';
  static const String _removeImageTitle = 'Retirar imagen';
  static const String _removeImageMessage =
      '¿Retirar la imagen de esta universidad?';
  static const String _cancelLabel = 'Cancelar';
  static const String _removeLabel = 'Retirar';
  static const String _pickImageTooltip = 'Elegir imagen';
  static const String _removeImageTooltip = 'Retirar imagen';

  final UniversityImageStorageService _imageStorageService =
      UniversityImageStorageService();
  final UniversityGalleryService _galleryService = UniversityGalleryService();
  final TextEditingController _studentCountController = TextEditingController();
  final GlobalKey<FormState> _studentCountFormKey = GlobalKey<FormState>();

  late final University _university;
  File? _storedImage;
  File? _previewImage;
  bool _removesStoredImage = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _rememberUniversity();
    _rememberStudentCount();
    unawaited(_loadStoredImage());
  }

  void _rememberUniversity() {
    _university = widget.university;
  }

  void _rememberStudentCount() {
    final studentCount = _university.studentCount;
    if (studentCount == null) {
      return;
    }
    _studentCountController.text = studentCount.toString();
  }

  Future<void> _loadStoredImage() async {
    final fileName = _readStoredImageFileName();
    if (fileName == null) {
      return;
    }
    try {
      final image = await _imageStorageService.findStoredImage(fileName);
      _showStoredImage(image);
    } catch (_) {
      _showStoredImage(null);
    }
  }

  void _showStoredImage(File? image) {
    if (!_canShowStoredImage()) {
      return;
    }
    setState(() {
      _storedImage = image;
    });
  }

  bool _canShowStoredImage() {
    if (!mounted || _removesStoredImage) {
      return false;
    }
    final hasPreviewImage = _previewImage != null;
    return !hasPreviewImage;
  }

  @override
  void dispose() {
    _studentCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody(context));
  }

  PreferredSizeWidget _buildAppBar() {
    return const AppBarComponent(title: _pageTitle, icon: Icons.school_outlined);
  }

  Widget _buildBody(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: _buildWidthLimitedDetail(context),
    );
  }

  Widget _buildWidthLimitedDetail(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: _maxContentWidth + (_horizontalPadding * 2),
      ),
      child: _buildDetailForm(context),
    );
  }

  Widget _buildDetailForm(BuildContext context) {
    return Form(
      key: _studentCountFormKey,
      child: ListView(
        padding: const EdgeInsets.all(_horizontalPadding),
        children: _buildDetailChildren(context),
      ),
    );
  }

  List<Widget> _buildDetailChildren(BuildContext context) {
    return [
      _buildHeader(context),
      const SizedBox(height: _sectionGap),
      _buildName(context),
      const SizedBox(height: _blockGap),
      _buildLocationRow(context),
      const SizedBox(height: _sectionGap),
      _buildDomainSection(context),
      const SizedBox(height: _sectionGap),
      _buildWebPageSection(context),
      const SizedBox(height: _sectionGap),
      _buildStudentCountEditor(context),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cardRadius),
      child: SizedBox(
        height: _headerHeight,
        width: double.infinity,
        child: _buildHeaderStack(context),
      ),
    );
  }

  Widget _buildHeaderStack(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildImageBanner()),
        _buildImageActions(context),
      ],
    );
  }

  Widget _buildImageBanner() {
    return UniversityImageBanner(
      university: _university,
      imageFile: _readVisibleImage(),
      loadsStoredImage: false,
    );
  }

  File? _readVisibleImage() {
    final previewImage = _previewImage;
    if (previewImage != null) {
      return previewImage;
    }
    if (_removesStoredImage) {
      return null;
    }
    return _storedImage;
  }

  Widget _buildImageActions(BuildContext context) {
    return Positioned(
      right: _actionInset,
      bottom: _actionInset,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildImageActionButtons(context),
      ),
    );
  }

  List<Widget> _buildImageActionButtons(BuildContext context) {
    final actions = <Widget>[_buildPickImageAction(context)];
    if (_showsVisibleImage()) {
      actions.add(const SizedBox(width: _actionGap));
      actions.add(_buildRemoveImageAction(context));
    }
    return actions;
  }

  bool _showsVisibleImage() {
    return _readVisibleImage() != null;
  }

  Widget _buildPickImageAction(BuildContext context) {
    return _buildImageAction(
      context,
      icon: Icons.add_photo_alternate_outlined,
      tooltip: _pickImageTooltip,
      onPressed: _readPickImageAction(),
    );
  }

  VoidCallback? _readPickImageAction() {
    if (_isSaving) {
      return null;
    }
    return _pickImage;
  }

  Widget _buildRemoveImageAction(BuildContext context) {
    return _buildImageAction(
      context,
      icon: Icons.delete_outline,
      tooltip: _removeImageTooltip,
      onPressed: _readRemoveImageAction(),
    );
  }

  VoidCallback? _readRemoveImageAction() {
    if (_isSaving) {
      return null;
    }
    return _requestImageRemoval;
  }

  Widget _buildImageAction(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: colorScheme.onSurface),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final image = await _galleryService.pickImage();
      _showPickedImage(image);
    } catch (_) {
      _showGalleryFailure();
    }
  }

  void _showPickedImage(File? image) {
    if (image == null || !mounted) {
      return;
    }
    setState(() {
      _previewImage = image;
      _removesStoredImage = false;
    });
  }

  void _showGalleryFailure() {
    _showMessage(_galleryFailureMessage);
  }

  Future<void> _requestImageRemoval() async {
    final removesImage = await _confirmImageRemoval();
    if (!removesImage) {
      return;
    }
    _clearVisibleImage();
  }

  Future<bool> _confirmImageRemoval() async {
    final removesImage = await showDialog<bool>(
      context: context,
      builder: _buildImageRemovalDialog,
    );
    if (!mounted) {
      return false;
    }
    return removesImage ?? false;
  }

  Widget _buildImageRemovalDialog(BuildContext context) {
    return AlertDialog(
      title: const Text(_removeImageTitle),
      content: const Text(_removeImageMessage),
      actions: _buildImageRemovalActions(context),
    );
  }

  List<Widget> _buildImageRemovalActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => _closeImageRemovalDialog(context, false),
        child: const Text(_cancelLabel),
      ),
      TextButton(
        onPressed: () => _closeImageRemovalDialog(context, true),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        child: const Text(_removeLabel),
      ),
    ];
  }

  void _closeImageRemovalDialog(BuildContext context, bool removesImage) {
    Navigator.of(context).pop(removesImage);
  }

  void _clearVisibleImage() {
    if (!mounted) {
      return;
    }
    setState(() {
      _previewImage = null;
      _removesStoredImage = true;
    });
  }

  Widget _buildName(BuildContext context) {
    return Text(_university.name, style: _readNameStyle(context));
  }

  TextStyle _readNameStyle(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    return (titleStyle ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildLocationRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildLocationLabel(context)),
        const SizedBox(width: _blockGap),
        _buildCountryCodeChip(context),
      ],
    );
  }

  Widget _buildLocationLabel(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: _iconSize,
          color: _readInfoColor(context),
        ),
        const SizedBox(width: _iconGap),
        Expanded(child: _buildInfoText(context, _readLocationLabel())),
      ],
    );
  }

  Widget _buildInfoText(BuildContext context, String label) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _readInfoTextStyle(context),
    );
  }

  TextStyle _readInfoTextStyle(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    return (bodyStyle ?? const TextStyle()).copyWith(
      color: _readInfoColor(context),
    );
  }

  Color _readInfoColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  String _readLocationLabel() {
    final province = _readStateProvince();
    if (province == null) {
      return _university.country;
    }
    return '${_university.country} · $province';
  }

  String? _readStateProvince() {
    final province = _university.stateProvince?.trim() ?? '';
    if (province.isEmpty) {
      return null;
    }
    return province;
  }

  Widget _buildCountryCodeChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(_university.alphaTwoCode),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: colorScheme.secondaryContainer,
      side: BorderSide.none,
      labelStyle: _readCountryCodeTextStyle(context),
    );
  }

  TextStyle _readCountryCodeTextStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return (labelStyle ?? const TextStyle()).copyWith(
      color: colorScheme.onSecondaryContainer,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildDomainSection(BuildContext context) {
    return _buildSection(
      context,
      title: _domainSectionTitle,
      content: _buildValueList(
        context,
        values: _university.domains,
        emptyLabel: _emptyDomainLabel,
      ),
    );
  }

  Widget _buildWebPageSection(BuildContext context) {
    return _buildSection(
      context,
      title: _webPageSectionTitle,
      content: _buildValueList(
        context,
        values: _university.webPages,
        emptyLabel: _emptyWebPageLabel,
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(context, title),
        const SizedBox(height: _rowGap),
        content,
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Text(title, style: titleStyle);
  }

  Widget _buildValueList(
    BuildContext context, {
    required List<String> values,
    required String emptyLabel,
  }) {
    final visibleValues = _readVisibleTexts(values);
    if (visibleValues.isEmpty) {
      return _buildBodyText(context, emptyLabel);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildValueLines(context, visibleValues),
    );
  }

  List<String> _readVisibleTexts(List<String> values) {
    return values.map(_trimText).where(_textHasContent).toList();
  }

  String _trimText(String value) {
    return value.trim();
  }

  bool _textHasContent(String value) {
    return value.isNotEmpty;
  }

  List<Widget> _buildValueLines(BuildContext context, List<String> values) {
    final lines = <Widget>[];
    for (var index = 0; index < values.length; index++) {
      _appendValueLine(lines, context, values, index);
    }
    return lines;
  }

  void _appendValueLine(
    List<Widget> lines,
    BuildContext context,
    List<String> values,
    int index,
  ) {
    if (_needsGapBeforeValue(index)) {
      lines.add(const SizedBox(height: _valueGap));
    }
    lines.add(_buildBodyText(context, values[index]));
  }

  bool _needsGapBeforeValue(int index) {
    return index > 0;
  }

  Widget _buildBodyText(BuildContext context, String value) {
    return Text(value, style: _readBodyTextStyle(context));
  }

  TextStyle _readBodyTextStyle(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyLarge;
    return bodyStyle ?? const TextStyle();
  }

  Widget _buildStudentCountEditor(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildStudentCountField()),
        const SizedBox(width: _rowGap),
        _buildSaveStudentCountButton(context),
      ],
    );
  }

  Widget _buildStudentCountField() {
    return TextFormField(
      controller: _studentCountController,
      enabled: !_isSaving,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: _buildStudentCountFormatters(),
      decoration: _buildStudentCountDecoration(),
      validator: _validateStudentCount,
    );
  }

  List<TextInputFormatter> _buildStudentCountFormatters() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(_maximumStudentDigits),
    ];
  }

  InputDecoration _buildStudentCountDecoration() {
    return const InputDecoration(
      labelText: _studentCountLabel,
      helperText: _studentCountHelper,
      helperMaxLines: 3,
    );
  }

  String? _validateStudentCount(String? value) {
    final studentCountText = value?.trim() ?? '';
    if (_studentCountTextIsEmpty(studentCountText)) {
      return null;
    }
    if (!_studentCountHasOnlyDigits(studentCountText)) {
      return _invalidStudentCountMessage;
    }
    return _validateParsedStudentCount(studentCountText);
  }

  bool _studentCountTextIsEmpty(String studentCountText) {
    return studentCountText.isEmpty;
  }

  bool _studentCountHasOnlyDigits(String studentCountText) {
    return RegExp(r'^[0-9]+$').hasMatch(studentCountText);
  }

  String? _validateParsedStudentCount(String studentCountText) {
    final studentCount = int.tryParse(studentCountText);
    if (_studentCountIsNotPositive(studentCount)) {
      return _nonPositiveStudentCountMessage;
    }
    if (_studentCountExceedsLimit(studentCount)) {
      return _studentCountLimitMessage;
    }
    return null;
  }

  bool _studentCountIsNotPositive(int? studentCount) {
    if (studentCount == null) {
      return true;
    }
    return studentCount <= 0;
  }

  bool _studentCountExceedsLimit(int? studentCount) {
    if (studentCount == null) {
      return false;
    }
    return studentCount > _maximumStudentCount;
  }

  Widget _buildSaveStudentCountButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: _saveButtonTopPadding),
      child: IconButton.filled(
        tooltip: _saveStudentCountTooltip,
        onPressed: _saveUniversity,
        icon: _buildSaveStudentCountIcon(context),
      ),
    );
  }

  Widget _buildSaveStudentCountIcon(BuildContext context) {
    if (_isSaving) {
      return _buildSaveIndicator(context);
    }
    return const Icon(Icons.check);
  }

  Widget _buildSaveIndicator(BuildContext context) {
    return SizedBox(
      width: _saveIndicatorSize,
      height: _saveIndicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Future<void> _saveUniversity() async {
    if (_isSaving || !_studentCountIsValid()) {
      return;
    }
    _markAsSaving();
    try {
      final university = await _buildSavedUniversity();
      _closeWithUniversity(university);
    } catch (_) {
      _showSaveFailure();
      _markAsNotSaving();
    }
  }

  bool _studentCountIsValid() {
    final form = _studentCountFormKey.currentState;
    if (form == null) {
      return false;
    }
    return form.validate();
  }

  void _markAsSaving() {
    setState(() {
      _isSaving = true;
    });
  }

  Future<University> _buildSavedUniversity() async {
    final imageFileName = await _resolveImageFileName();
    final studentCount = _readStudentCount();
    return _university.withUserProvidedData(
      imageFileName: imageFileName,
      studentCount: studentCount,
    );
  }

  Future<String?> _resolveImageFileName() async {
    final previewImage = _previewImage;
    if (previewImage != null) {
      return _storePreviewImage(previewImage);
    }
    if (_removesStoredImage) {
      await _deleteStoredImage();
      return null;
    }
    return _readStoredImageFileName();
  }

  Future<String> _storePreviewImage(File previewImage) async {
    final storedFileName = await _imageStorageService.saveImage(previewImage);
    await _deletePreviousImage(storedFileName);
    return storedFileName;
  }

  Future<void> _deletePreviousImage(String storedFileName) async {
    final previousFileName = _readStoredImageFileName();
    if (previousFileName == null || previousFileName == storedFileName) {
      return;
    }
    await _imageStorageService.deleteImage(previousFileName);
  }

  Future<void> _deleteStoredImage() async {
    final storedFileName = _readStoredImageFileName();
    if (storedFileName == null) {
      return;
    }
    await _imageStorageService.deleteImage(storedFileName);
  }

  String? _readStoredImageFileName() {
    final storedFileName = _university.imageFileName?.trim() ?? '';
    if (storedFileName.isEmpty) {
      return null;
    }
    return storedFileName;
  }

  int? _readStudentCount() {
    final studentCountText = _studentCountController.text.trim();
    if (_studentCountTextIsEmpty(studentCountText)) {
      return null;
    }
    return int.parse(studentCountText);
  }

  void _closeWithUniversity(University university) {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(university);
  }

  void _showSaveFailure() {
    _showMessage(_saveFailureMessage);
  }

  void _markAsNotSaving() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isSaving = false;
    });
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
