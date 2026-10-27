import 'dart:async';

import 'package:flutter/material.dart';
import 'package:universities_app/models/university.dart';
import 'package:universities_app/services/university_service.dart';
import 'package:universities_app/widgets/university_card.dart';

class UniversityCardList extends StatefulWidget {
  const UniversityCardList({
    super.key,
    this.layout = UniversityCardLayout.full,
    this.showsOnlyLoadedData = false,
  });

  final UniversityCardLayout layout;
  final bool showsOnlyLoadedData;

  @override
  State<UniversityCardList> createState() => _UniversityCardListState();
}

class _UniversityCardListState extends State<UniversityCardList> {
  static const double _horizontalPadding = 16;
  static const double _verticalPadding = 16;
  static const double _cardGap = 16;
  static const double _fullMaxWidth = 480;
  static const double _gridMaxWidth = 720;
  static const int _gridColumnCount = 2;
  static const int _visibleUniversityLimit = 20;
  static const String _emptyMessage = 'Sin datos';
  static const String _errorMessage = 'No fue posible cargar las universidades';
  static const String _retryLabel = 'Reintentar';
  static const double _statusGap = 12;
  static const Duration _fadeDuration = Duration(milliseconds: 180);

  final UniversityService _universityService = UniversityService();
  List<University> _universities = const <University>[];
  bool _isLoadingUniversities = true;
  bool _failedToLoadUniversities = false;
  late UniversityCardLayout _visibleLayout;
  late bool _visibleShowsOnlyLoadedData;
  double _contentOpacity = 1;
  int _contentFadeGeneration = 0;

  @override
  void initState() {
    super.initState();
    _rememberInitialSelection();
    unawaited(_loadUniversities());
  }

  Future<void> _loadUniversities() async {
    try {
      final universities = await _universityService.loadUniversities();
      _showLoadedUniversities(universities);
    } catch (_) {
      _showUniversityLoadFailure();
    }
  }

  void _showLoadedUniversities(List<University> universities) {
    if (_widgetIsUnmounted()) {
      return;
    }
    setState(() {
      _universities = _readUniversitiesToPaint(universities);
      _isLoadingUniversities = false;
      _failedToLoadUniversities = false;
    });
  }

  List<University> _readUniversitiesToPaint(List<University> universities) {
    return universities.take(_visibleUniversityLimit).toList();
  }

  void _showUniversityLoadFailure() {
    if (_widgetIsUnmounted()) {
      return;
    }
    setState(() {
      _isLoadingUniversities = false;
      _failedToLoadUniversities = true;
    });
  }

  bool _widgetIsUnmounted() {
    final widgetIsUnmounted = !mounted;
    return widgetIsUnmounted;
  }

  void _retryLoadUniversities() {
    _markUniversitiesAsLoading();
    unawaited(_loadUniversities());
  }

  void _markUniversitiesAsLoading() {
    setState(() {
      _isLoadingUniversities = true;
      _failedToLoadUniversities = false;
    });
  }

  void _rememberInitialSelection() {
    _visibleLayout = widget.layout;
    _visibleShowsOnlyLoadedData = widget.showsOnlyLoadedData;
  }

  @override
  void didUpdateWidget(UniversityCardList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fadeWhenSelectionChanges(oldWidget);
  }

  void _fadeWhenSelectionChanges(UniversityCardList oldWidget) {
    if (_selectionChanged(oldWidget)) {
      unawaited(_playContentFade());
    }
  }

  bool _selectionChanged(UniversityCardList oldWidget) {
    final layoutChanged = widget.layout != oldWidget.layout;
    final filterChanged =
        widget.showsOnlyLoadedData != oldWidget.showsOnlyLoadedData;
    return layoutChanged || filterChanged;
  }

  Future<void> _playContentFade() async {
    final fadeGeneration = _beginContentFade();
    await Future<void>.delayed(_fadeDuration);
    if (_canRevealIncomingContent(fadeGeneration)) {
      _revealIncomingContent();
    }
  }

  int _beginContentFade() {
    _contentFadeGeneration += 1;
    final fadeGeneration = _contentFadeGeneration;
    _hideVisibleContent();
    return fadeGeneration;
  }

  void _hideVisibleContent() {
    setState(() {
      _contentOpacity = 0;
    });
  }

  bool _canRevealIncomingContent(int fadeGeneration) {
    final fadeIsCurrent = fadeGeneration == _contentFadeGeneration;
    final widgetIsMounted = mounted;
    return fadeIsCurrent && widgetIsMounted;
  }

  void _revealIncomingContent() {
    setState(() {
      _visibleLayout = widget.layout;
      _visibleShowsOnlyLoadedData = widget.showsOnlyLoadedData;
      _contentOpacity = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildFadedContent(context);
  }

  Widget _buildFadedContent(BuildContext context) {
    return AnimatedOpacity(
      opacity: _contentOpacity,
      duration: _fadeDuration,
      curve: Curves.easeInOut,
      child: _buildVisibleContent(context),
    );
  }

  Widget _buildVisibleContent(BuildContext context) {
    if (_isLoadingUniversities) {
      return _buildLoadingIndicator();
    }
    if (_failedToLoadUniversities) {
      return _buildLoadError(context);
    }
    final universities = _readVisibleUniversities();
    if (_visibleUniversitiesAreEmpty(universities)) {
      return _buildStatusMessage(context, _emptyMessage);
    }
    return _buildScrollableCards(universities);
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLoadError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusText(context, _errorMessage),
          const SizedBox(height: _statusGap),
          _buildRetryButton(),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return TextButton(
      onPressed: _retryLoadUniversities,
      child: const Text(_retryLabel),
    );
  }

  List<University> _readVisibleUniversities() {
    if (_showsEveryUniversity()) {
      return _universities;
    }
    return _keepUniversitiesWithUserProvidedData(_universities);
  }

  bool _showsEveryUniversity() {
    final showsEveryUniversity = !_visibleShowsOnlyLoadedData;
    return showsEveryUniversity;
  }

  List<University> _keepUniversitiesWithUserProvidedData(
    List<University> universities,
  ) {
    return universities.where(_universityHasUserProvidedData).toList();
  }

  bool _universityHasUserProvidedData(University university) {
    return university.hasUserProvidedData();
  }

  bool _visibleUniversitiesAreEmpty(List<University> universities) {
    final universitiesAreEmpty = universities.isEmpty;
    return universitiesAreEmpty;
  }

  Widget _buildStatusMessage(BuildContext context, String message) {
    return Center(child: _buildStatusText(context, message));
  }

  Widget _buildStatusText(BuildContext context, String message) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: _readEmptyMessageStyle(context),
    );
  }

  TextStyle _readEmptyMessageStyle(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final resolvedStyle = textStyle ?? const TextStyle();
    return resolvedStyle.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  Widget _buildScrollableCards(List<University> universities) {
    return Align(
      alignment: Alignment.topCenter,
      child: _buildWidthLimitedList(universities),
    );
  }

  Widget _buildWidthLimitedList(List<University> universities) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _readScrollViewportWidth()),
      child: _buildLazyCards(universities),
    );
  }

  double _readScrollViewportWidth() {
    return _readMaxContentWidth() + (_horizontalPadding * 2);
  }

  Widget _buildLazyCards(List<University> universities) {
    if (_usesGridLayout()) {
      return _buildLazyGrid(universities);
    }
    return _buildLazyFullList(universities);
  }

  Widget _buildLazyFullList(List<University> universities) {
    return ListView.separated(
      padding: _readListPadding(),
      itemCount: universities.length,
      separatorBuilder: _buildCardSeparator,
      itemBuilder: (context, index) => _buildListedCard(universities, index),
    );
  }

  Widget _buildListedCard(List<University> universities, int index) {
    return _buildCard(universities[index]);
  }

  Widget _buildLazyGrid(List<University> universities) {
    return ListView.separated(
      padding: _readListPadding(),
      itemCount: _readGridRowCount(universities),
      separatorBuilder: _buildCardSeparator,
      itemBuilder: (context, index) => _buildGridRow(universities, index),
    );
  }

  int _readGridRowCount(List<University> universities) {
    return (universities.length / _gridColumnCount).ceil();
  }

  Widget _buildCardSeparator(BuildContext context, int index) {
    return const SizedBox(height: _cardGap);
  }

  EdgeInsets _readListPadding() {
    return const EdgeInsets.symmetric(
      horizontal: _horizontalPadding,
      vertical: _verticalPadding,
    );
  }

  Widget _buildGridRow(List<University> universities, int rowIndex) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildGridRowChildren(universities, rowIndex),
    );
  }

  List<Widget> _buildGridRowChildren(
    List<University> universities,
    int rowIndex,
  ) {
    final children = <Widget>[];
    for (var column = 0; column < _gridColumnCount; column++) {
      _appendGridRowChild(children, universities, rowIndex, column);
    }
    return children;
  }

  void _appendGridRowChild(
    List<Widget> children,
    List<University> universities,
    int rowIndex,
    int column,
  ) {
    if (_needsGapBeforeGridColumn(column)) {
      children.add(const SizedBox(width: _cardGap));
    }
    children.add(_buildGridRowSlot(universities, rowIndex, column));
  }

  bool _needsGapBeforeGridColumn(int column) {
    final needsGap = column > 0;
    return needsGap;
  }

  Widget _buildGridRowSlot(
    List<University> universities,
    int rowIndex,
    int column,
  ) {
    final index = _readGridItemIndex(rowIndex, column);
    if (_indexIsOutsideUniversities(universities, index)) {
      return const Expanded(child: SizedBox.shrink());
    }
    return Expanded(child: _buildCard(universities[index]));
  }

  int _readGridItemIndex(int rowIndex, int column) {
    return (rowIndex * _gridColumnCount) + column;
  }

  bool _indexIsOutsideUniversities(List<University> universities, int index) {
    final indexIsOutsideUniversities = index >= universities.length;
    return indexIsOutsideUniversities;
  }

  double _readMaxContentWidth() {
    if (_usesGridLayout()) {
      return _gridMaxWidth;
    }
    return _fullMaxWidth;
  }

  bool _usesGridLayout() {
    final usesGridLayout = _visibleLayout == UniversityCardLayout.grid;
    return usesGridLayout;
  }

  Widget _buildCard(University university) {
    return UniversityCard(university: university, layout: _visibleLayout);
  }
}
