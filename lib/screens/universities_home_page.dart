import 'package:flutter/material.dart';
import 'package:universities_app/widgets/app_bar_component.dart';
import 'package:universities_app/widgets/university_card_list.dart';

class UniversitiesHomePage extends StatelessWidget {
  const UniversitiesHomePage({super.key});

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
    return const UniversityCardList();
  }
}
