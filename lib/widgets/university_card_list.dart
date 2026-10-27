import 'dart:async';

import 'package:flutter/material.dart';
import 'package:universities_app/models/university.dart';
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
  static const String _emptyMessage = 'Sin datos';
  static const Duration _fadeDuration = Duration(milliseconds: 180);

  late UniversityCardLayout _visibleLayout;
  late bool _visibleShowsOnlyLoadedData;
  double _contentOpacity = 1;
  int _contentFadeGeneration = 0;

  @override
  void initState() {
    super.initState();
    _rememberInitialSelection();
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
    final universities = _readVisibleUniversities();
    if (_visibleUniversitiesAreEmpty(universities)) {
      return _buildEmptyMessage(context);
    }
    return _buildScrollableCards(universities);
  }

  List<University> _readVisibleUniversities() {
    final universities = _createPreviewUniversities();
    if (_showsEveryUniversity()) {
      return universities;
    }
    return _keepUniversitiesWithUserProvidedData(universities);
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

  Widget _buildEmptyMessage(BuildContext context) {
    return Center(
      child: Text(_emptyMessage, style: _readEmptyMessageStyle(context)),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: _buildCenteredContent(universities),
    );
  }

  Widget _buildCenteredContent(List<University> universities) {
    return Align(
      alignment: Alignment.topCenter,
      child: _buildWidthLimitedContent(universities),
    );
  }

  Widget _buildWidthLimitedContent(List<University> universities) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _readMaxContentWidth()),
      child: _buildCards(universities),
    );
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

  Widget _buildCards(List<University> universities) {
    if (_usesGridLayout()) {
      return _buildGrid(universities);
    }
    return _buildFullColumn(universities);
  }

  Widget _buildFullColumn(List<University> universities) {
    return Column(children: _buildFullCards(universities));
  }

  List<Widget> _buildFullCards(List<University> universities) {
    final cards = <Widget>[];
    for (var index = 0; index < universities.length; index++) {
      _appendFullCard(cards, universities[index], index);
    }
    return cards;
  }

  void _appendFullCard(List<Widget> cards, University university, int index) {
    if (_needsGapBeforeCard(index)) {
      cards.add(const SizedBox(height: _cardGap));
    }
    cards.add(_buildCard(university));
  }

  bool _needsGapBeforeCard(int index) {
    final needsGap = index > 0;
    return needsGap;
  }

  Widget _buildGrid(List<University> universities) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildGridWrap(universities, constraints.maxWidth);
      },
    );
  }

  Widget _buildGridWrap(List<University> universities, double availableWidth) {
    final cardWidth = _readGridCardWidth(availableWidth);
    return Wrap(
      spacing: _cardGap,
      runSpacing: _cardGap,
      children: _buildGridCards(universities, cardWidth),
    );
  }

  double _readGridCardWidth(double availableWidth) {
    final totalGap = _cardGap * (_gridColumnCount - 1);
    final usableWidth = availableWidth - totalGap;
    if (_usableWidthIsPositive(usableWidth)) {
      return usableWidth / _gridColumnCount;
    }
    return availableWidth;
  }

  bool _usableWidthIsPositive(double usableWidth) {
    final usableWidthIsPositive = usableWidth > 0;
    return usableWidthIsPositive;
  }

  List<Widget> _buildGridCards(
    List<University> universities,
    double cardWidth,
  ) {
    final cards = <Widget>[];
    for (final university in universities) {
      _appendGridCard(cards, university, cardWidth);
    }
    return cards;
  }

  void _appendGridCard(
    List<Widget> cards,
    University university,
    double cardWidth,
  ) {
    cards.add(_buildGridCard(university, cardWidth));
  }

  Widget _buildGridCard(University university, double cardWidth) {
    return SizedBox(width: cardWidth, child: _buildCard(university));
  }

  Widget _buildCard(University university) {
    return UniversityCard(university: university, layout: _visibleLayout);
  }

  List<University> _createPreviewUniversities() {
    return [
      _createNationalUniversityOfColombia(),
      _createUniversityOfTheAndes(),
      _createMassachusettsInstituteOfTechnology(),
      _createUniversityOfOxford(),
      _createUniversityOfBuenosAires(),
      _createNationalAutonomousUniversityOfMexico(),
      _createUniversityOfSaoPaulo(),
      _createUniversityOfTokyo(),
      _createSorbonneUniversity(),
      _createUniversityOfToronto(),
    ];
  }

  University _createNationalUniversityOfColombia() {
    return const University(
      name: 'Universidad Nacional de Colombia',
      webPages: ['https://unal.edu.co'],
      domains: ['unal.edu.co'],
      stateProvince: 'Bogotá',
      studentCount: null,
      country: 'Colombia',
      alphaTwoCode: 'CO',
    );
  }

  University _createUniversityOfTheAndes() {
    return const University(
      webPages: ['https://uniandes.edu.co'],
      name: 'Universidad de los Andes',
      domains: ['uniandes.edu.co'],
      stateProvince: 'Bogotá',
      studentCount: 19000,
      country: 'Colombia',
      alphaTwoCode: 'CO',
    );
  }

  University _createMassachusettsInstituteOfTechnology() {
    return const University(
      name: 'Massachusetts Institute of Technology',
      webPages: ['https://www.mit.edu'],
      stateProvince: 'Massachusetts',
      country: 'United States',
      domains: ['mit.edu'],
      studentCount: 11900,
      alphaTwoCode: 'US',
    );
  }

  University _createUniversityOfOxford() {
    return const University(
      webPages: ['https://www.ox.ac.uk'],
      name: 'University of Oxford',
      country: 'United Kingdom',
      domains: ['ox.ac.uk'],
      studentCount: 26000,
      stateProvince: null,
      alphaTwoCode: 'GB',
    );
  }

  University _createUniversityOfBuenosAires() {
    return const University(
      name: 'Universidad de Buenos Aires',
      webPages: ['https://www.uba.ar'],
      stateProvince: 'Buenos Aires',
      studentCount: 320000,
      country: 'Argentina',
      domains: ['uba.ar'],
      alphaTwoCode: 'AR',
    );
  }

  University _createNationalAutonomousUniversityOfMexico() {
    return const University(
      name: 'Universidad Nacional Autónoma de México',
      webPages: ['https://www.unam.mx'],
      stateProvince: 'Ciudad de México',
      domains: ['unam.mx'],
      studentCount: 360000,
      alphaTwoCode: 'MX',
      country: 'Mexico',
    );
  }

  University _createUniversityOfSaoPaulo() {
    return const University(
      name: 'Universidade de São Paulo',
      webPages: ['https://www.usp.br'],
      stateProvince: 'São Paulo',
      domains: ['usp.br'],
      studentCount: 90000,
      alphaTwoCode: 'BR',
      country: 'Brazil',
    );
  }

  University _createUniversityOfTokyo() {
    return const University(
      webPages: ['https://www.u-tokyo.ac.jp'],
      name: 'University of Tokyo',
      domains: ['u-tokyo.ac.jp'],
      stateProvince: 'Tokyo',
      alphaTwoCode: 'JP',
      country: 'Japan',
    );
  }

  University _createSorbonneUniversity() {
    return const University(
      webPages: ['https://www.sorbonne-universite.fr'],
      domains: ['sorbonne-universite.fr'],
      stateProvince: 'Île-de-France',
      name: 'Sorbonne Université',
      studentCount: 55000,
      alphaTwoCode: 'FR',
      country: 'France',
    );
  }

  University _createUniversityOfToronto() {
    return const University(
      webPages: ['https://www.utoronto.ca'],
      name: 'University of Toronto',
      stateProvince: 'Ontario',
      domains: ['utoronto.ca'],
      studentCount: 97000,
      alphaTwoCode: 'CA',
      country: 'Canada',
    );
  }
}
