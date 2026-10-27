import 'package:flutter/material.dart';
import 'package:universities_app/models/university.dart';
import 'package:universities_app/widgets/university_image_banner.dart';

enum UniversityCardLayout { full, grid }

class UniversityCard extends StatelessWidget {
  const UniversityCard({
    super.key,
    required this.university,
    this.layout = UniversityCardLayout.full,
    this.onTap,
  });

  final University university;
  final UniversityCardLayout layout;
  final VoidCallback? onTap;

  static const double _fullHeaderHeight = 120;
  static const double _gridHeaderHeight = 88;
  static const double _cardRadius = 20;
  static const double _contentPadding = 16;
  static const double _sectionGap = 12;
  static const double _rowGap = 8;
  static const double _iconSize = 18;
  static const double _iconGap = 8;
  static const int _titleLineCount = 1;
  static const double _fallbackTitleFontSize = 16;
  static const double _fallbackTitleHeightFactor = 1.5;
  static const double _fallbackBodyFontSize = 14;
  static const double _fallbackBodyHeightFactor = 1.43;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, child: _buildCard(context));
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface,
      shape: _buildCardShape(context),
      child: _buildTappableBody(context),
    );
  }

  Widget _buildTappableBody(BuildContext context) {
    final body = _buildCardBody(context);
    if (_respondsToTap()) {
      return InkWell(onTap: onTap, child: body);
    }
    return body;
  }

  bool _respondsToTap() {
    final respondsToTap = onTap != null;
    return respondsToTap;
  }

  RoundedRectangleBorder _buildCardShape(BuildContext context) {
    final outlineColor = Theme.of(context).colorScheme.outlineVariant;
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_cardRadius),
      side: BorderSide(color: outlineColor),
    );
  }

  Widget _buildCardBody(BuildContext context) {
    if (_usesGridLayout()) {
      return _buildGridBody(context);
    }
    return _buildFullBody(context);
  }

  bool _usesGridLayout() {
    final usesGridLayout = layout == UniversityCardLayout.grid;
    return usesGridLayout;
  }

  Widget _buildFullBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_buildFullHeader(context), _buildFullContent(context)],
    );
  }

  Widget _buildFullHeader(BuildContext context) {
    return SizedBox(
      height: _fullHeaderHeight,
      child: UniversityImageBanner(university: university),
    );
  }

  Widget _buildFullContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_contentPadding),
      child: _buildFullDetails(context),
    );
  }

  Widget _buildFullDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildName(context),
        const SizedBox(height: _sectionGap),
        _buildInfoRow(
          context,
          icon: Icons.location_on_outlined,
          label: _buildLocationLabel(),
        ),
        const SizedBox(height: _rowGap),
        _buildInfoRow(
          context,
          icon: Icons.groups_outlined,
          label: _buildStudentsLabel(),
        ),
        _buildFullFooter(context),
      ],
    );
  }

  Widget _buildFullFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildDomainRow(context)),
        const SizedBox(width: _sectionGap),
        _buildCountryCodeChip(context),
      ],
    );
  }

  Widget _buildDomainRow(BuildContext context) {
    return _buildInfoRow(
      context,
      icon: Icons.language,
      label: _buildDomainLabel(),
    );
  }

  Widget _buildGridBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_buildGridHeader(context), _buildGridContent(context)],
    );
  }

  Widget _buildGridHeader(BuildContext context) {
    return SizedBox(
      height: _gridHeaderHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: UniversityImageBanner(
              university: university,
              usesCompactIdentity: true,
            ),
          ),
          _buildGridCountryCode(context),
        ],
      ),
    );
  }

  Widget _buildGridCountryCode(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 12,
      child: _buildCountryCodeChip(context),
    );
  }

  Widget _buildGridContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildName(context),
          const SizedBox(height: _sectionGap),
          _buildInfoRow(
            context,
            icon: Icons.location_on_outlined,
            label: _buildLocationLabel(),
          ),
        ],
      ),
    );
  }

  Widget _buildName(BuildContext context) {
    return SizedBox(
      height: _readTitleHeight(context),
      width: double.infinity,
      child: Text(
        university.name,
        maxLines: _titleLineCount,
        overflow: TextOverflow.ellipsis,
        style: _readTitleStyle(context),
      ),
    );
  }

  double _readTitleHeight(BuildContext context) {
    final titleStyle = _readTitleStyle(context);
    final fontSize = titleStyle.fontSize ?? _fallbackTitleFontSize;
    final heightFactor = titleStyle.height ?? _fallbackTitleHeightFactor;
    return fontSize * heightFactor * _titleLineCount;
  }

  TextStyle _readTitleStyle(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final resolvedStyle = titleStyle ?? const TextStyle();
    return resolvedStyle.copyWith(
      height: titleStyle?.height ?? _fallbackTitleHeightFactor,
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      height: _readInfoRowHeight(context),
      child: Row(
        children: [
          _buildInfoIcon(context, icon),
          const SizedBox(width: _iconGap),
          Expanded(child: _buildInfoLabel(context, label)),
        ],
      ),
    );
  }

  Widget _buildInfoIcon(BuildContext context, IconData icon) {
    return Icon(icon, size: _iconSize, color: _readInfoColor(context));
  }

  Widget _buildInfoLabel(BuildContext context, String label) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _readInfoTextStyle(context),
    );
  }

  double _readInfoRowHeight(BuildContext context) {
    final infoStyle = _readInfoTextStyle(context);
    final fontSize = infoStyle.fontSize ?? _fallbackBodyFontSize;
    final heightFactor = infoStyle.height ?? _fallbackBodyHeightFactor;
    final lineHeight = fontSize * heightFactor;
    final iconIsTaller = _iconSize > lineHeight;
    if (iconIsTaller) {
      return _iconSize;
    }
    return lineHeight;
  }

  TextStyle _readInfoTextStyle(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final resolvedStyle = bodyStyle ?? const TextStyle();
    return resolvedStyle.copyWith(
      color: _readInfoColor(context),
      height: bodyStyle?.height ?? _fallbackBodyHeightFactor,
    );
  }

  Color _readInfoColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Widget _buildCountryCodeChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(university.alphaTwoCode),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: colorScheme.secondaryContainer,
      side: BorderSide.none,
      labelStyle: _buildCountryCodeTextStyle(context),
    );
  }

  TextStyle _buildCountryCodeTextStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return (labelStyle ?? const TextStyle()).copyWith(
      color: colorScheme.onSecondaryContainer,
      fontWeight: FontWeight.w600,
    );
  }

  String _buildLocationLabel() {
    final province = _readStateProvince();
    if (province == null) {
      return university.country;
    }
    return '${university.country} · $province';
  }

  String? _readStateProvince() {
    final province = university.stateProvince?.trim() ?? '';
    final hasProvince = province.isNotEmpty;
    if (!hasProvince) {
      return null;
    }
    return province;
  }

  String _buildStudentsLabel() {
    final studentCount = university.studentCount;
    if (studentCount == null) {
      return 'Sin registro de estudiantes';
    }
    final formattedCount = _formatStudentCount(studentCount);
    return '$formattedCount estudiantes';
  }

  String _formatStudentCount(int studentCount) {
    final digits = studentCount.abs().toString().split('');
    final groupedDigits = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      _writeStudentCountDigit(groupedDigits, digits, index);
    }
    return _applyStudentCountSign(studentCount, groupedDigits.toString());
  }

  void _writeStudentCountDigit(
    StringBuffer groupedDigits,
    List<String> digits,
    int index,
  ) {
    if (_startsThousandsGroup(digits.length, index)) {
      groupedDigits.write('.');
    }
    groupedDigits.write(digits[index]);
  }

  bool _startsThousandsGroup(int digitCount, int index) {
    final distanceFromEnd = digitCount - index;
    final isGroupBoundary = distanceFromEnd % 3 == 0;
    final isNotFirstDigit = index > 0;
    return isGroupBoundary && isNotFirstDigit;
  }

  String _applyStudentCountSign(int studentCount, String formattedCount) {
    final isNegative = studentCount < 0;
    if (isNegative) {
      return '-$formattedCount';
    }
    return formattedCount;
  }

  String _buildDomainLabel() {
    final domain = _readFirstDomain();
    if (domain == null) {
      return 'Sin dominio';
    }
    return domain;
  }

  String? _readFirstDomain() {
    if (university.domains.isEmpty) {
      return null;
    }
    final domain = university.domains.first.trim();
    if (domain.isEmpty) {
      return null;
    }
    return domain;
  }
}
