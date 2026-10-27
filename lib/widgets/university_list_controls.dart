import 'package:flutter/material.dart';
import 'package:universities_app/widgets/university_card.dart';

class UniversityListControls extends StatelessWidget {
  const UniversityListControls({
    super.key,
    required this.layout,
    required this.showsOnlyLoadedData,
    required this.onLayoutChanged,
    required this.onLoadedDataFilterChanged,
  });

  final UniversityCardLayout layout;
  final bool showsOnlyLoadedData;
  final ValueChanged<UniversityCardLayout> onLayoutChanged;
  final ValueChanged<bool> onLoadedDataFilterChanged;

  static const double _horizontalPadding = 16;
  static const double _verticalPadding = 16;
  static const double _loadedDataIconSize = 18;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: _verticalPadding,
        left: _horizontalPadding,
        right: _horizontalPadding,
      ),
      child: _buildControls(context),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Row(
      children: [
        _buildLoadedDataFilter(),
        const Spacer(),
        _buildLayoutSelector(context),
      ],
    );
  }

  Widget _buildLoadedDataFilter() {
    return FilterChip(
      label: const Text('Datos extra'),
      avatar: const Icon(Icons.fact_check_outlined, size: _loadedDataIconSize),
      selected: showsOnlyLoadedData,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      onSelected: _notifyLoadedDataFilter,
    );
  }

  void _notifyLoadedDataFilter(bool showsOnlyLoadedData) {
    onLoadedDataFilterChanged(showsOnlyLoadedData);
  }

  Widget _buildLayoutSelector(BuildContext context) {
    return SegmentedButton<UniversityCardLayout>(
      segments: _buildLayoutSegments(),
      selected: {layout},
      showSelectedIcon: false,
      style: _buildLayoutSelectorStyle(context),
      onSelectionChanged: _notifyLayoutSelection,
    );
  }

  List<ButtonSegment<UniversityCardLayout>> _buildLayoutSegments() {
    return [_buildFullLayoutSegment(), _buildGridLayoutSegment()];
  }

  ButtonSegment<UniversityCardLayout> _buildFullLayoutSegment() {
    return const ButtonSegment<UniversityCardLayout>(
      value: UniversityCardLayout.full,
      icon: Icon(Icons.view_agenda_outlined),
      tooltip: 'Vista completa',
    );
  }

  ButtonSegment<UniversityCardLayout> _buildGridLayoutSegment() {
    return const ButtonSegment<UniversityCardLayout>(
      value: UniversityCardLayout.grid,
      icon: Icon(Icons.grid_view_outlined),
      tooltip: 'Vista en cuadrícula',
    );
  }

  ButtonStyle _buildLayoutSelectorStyle(BuildContext context) {
    return ButtonStyle(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: _buildLayoutSelectorBorder(context),
    );
  }

  WidgetStateProperty<BorderSide> _buildLayoutSelectorBorder(
    BuildContext context,
  ) {
    final borderColor = _readLoadedDataChipBorderColor(context);
    return WidgetStatePropertyAll(BorderSide(color: borderColor));
  }

  Color _readLoadedDataChipBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  void _notifyLayoutSelection(Set<UniversityCardLayout> selection) {
    final layout = _readSelectedLayout(selection);
    onLayoutChanged(layout);
  }

  UniversityCardLayout _readSelectedLayout(
    Set<UniversityCardLayout> selection,
  ) {
    return selection.first;
  }
}
