import 'package:flutter/material.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  const AppBarComponent({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  static const double _iconSize = 24;
  static const double _iconGap = 12;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _readBackgroundColor(context),
      foregroundColor: _readForegroundColor(context),
      surfaceTintColor: _readBackgroundColor(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: _buildTitle(context),
    );
  }

  Color _readBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  Color _readForegroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        _buildIcon(context),
        const SizedBox(width: _iconGap),
        Flexible(child: _buildTitleText(context)),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Icon(
      icon,
      size: _iconSize,
      color: _readForegroundColor(context),
    );
  }

  Widget _buildTitleText(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _readTitleStyle(context),
    );
  }

  TextStyle _readTitleStyle(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    return (titleStyle ?? const TextStyle()).copyWith(
      color: _readForegroundColor(context),
    );
  }
}
