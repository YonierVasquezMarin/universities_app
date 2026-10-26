import 'package:flutter/material.dart';
import 'package:universities_app/models/university.dart';
import 'package:universities_app/widgets/app_bar_component.dart';
import 'package:universities_app/widgets/university_card.dart';

class UniversitiesHomePage extends StatelessWidget {
  const UniversitiesHomePage({super.key});

  static const double _horizontalMargin = 16;
  static const double _verticalMargin = 24;
  static const double _maxCardWidth = 480;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  PreferredSizeWidget _buildAppBar() {
    return const AppBarComponent(
      title: 'Universidades',
      icon: Icons.school_outlined,
    );
  }

  Widget _buildBody() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalMargin,
          vertical: _verticalMargin,
        ),
        child: _buildExampleCard(),
      ),
    );
  }

  Widget _buildExampleCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxCardWidth),
      child: UniversityCard(university: _createExampleUniversity()),
    );
  }

  University _createExampleUniversity() {
    return const University(
      alphaTwoCode: 'CO',
      domains: ['unal.edu.co'],
      country: 'Colombia',
      stateProvince: 'Bogotá',
      webPages: ['https://unal.edu.co'],
      name: 'Universidad Nacional de Colombia',
      studentCount: 53000,
    );
  }
}
