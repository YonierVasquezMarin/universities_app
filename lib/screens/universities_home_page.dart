import 'package:flutter/material.dart';
import 'package:universities_app/widgets/app_bar_component.dart';
import 'package:universities_app/widgets/university_card.dart';
import 'package:universities_app/widgets/university_card_list.dart';
import 'package:universities_app/widgets/university_list_controls.dart';

class UniversitiesHomePage extends StatefulWidget {
  const UniversitiesHomePage({super.key});

  @override
  State<UniversitiesHomePage> createState() => _UniversitiesHomePageState();
}

class _UniversitiesHomePageState extends State<UniversitiesHomePage> {
  UniversityCardLayout _layout = UniversityCardLayout.full;
  bool _showsOnlyLoadedData = false;

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
    return Column(children: [_buildControls(), _buildExpandedCardList()]);
  }

  Widget _buildControls() {
    return UniversityListControls(
      layout: _layout,
      showsOnlyLoadedData: _showsOnlyLoadedData,
      onLayoutChanged: _applyLayout,
      onLoadedDataFilterChanged: _applyLoadedDataFilter,
    );
  }

  Widget _buildExpandedCardList() {
    return Expanded(child: _buildCardList());
  }

  Widget _buildCardList() {
    return UniversityCardList(
      layout: _layout,
      showsOnlyLoadedData: _showsOnlyLoadedData,
    );
  }

  void _applyLayout(UniversityCardLayout layout) {
    setState(() {
      _layout = layout;
    });
  }

  void _applyLoadedDataFilter(bool showsOnlyLoadedData) {
    setState(() {
      _showsOnlyLoadedData = showsOnlyLoadedData;
    });
  }
}
