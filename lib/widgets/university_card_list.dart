import 'package:flutter/material.dart';
import 'package:universities_app/models/university.dart';
import 'package:universities_app/widgets/university_card.dart';

class UniversityCardList extends StatelessWidget {
  const UniversityCardList({
    super.key,
    this.layout = UniversityCardLayout.full,
  });

  final UniversityCardLayout layout;

  static const double _horizontalPadding = 16;
  static const double _verticalPadding = 16;
  static const double _cardGap = 16;
  static const double _fullMaxWidth = 480;
  static const double _gridMaxWidth = 720;
  static const int _gridColumnCount = 2;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: _buildCenteredContent(),
    );
  }

  Widget _buildCenteredContent() {
    return Align(
      alignment: Alignment.topCenter,
      child: _buildWidthLimitedContent(),
    );
  }

  Widget _buildWidthLimitedContent() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _readMaxContentWidth()),
      child: _buildCards(),
    );
  }

  double _readMaxContentWidth() {
    if (_usesGridLayout()) {
      return _gridMaxWidth;
    }
    return _fullMaxWidth;
  }

  bool _usesGridLayout() {
    final usesGridLayout = layout == UniversityCardLayout.grid;
    return usesGridLayout;
  }

  Widget _buildCards() {
    final universities = _createPreviewUniversities();
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
    return UniversityCard(university: university, layout: layout);
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
      studentCount: 53000,
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
