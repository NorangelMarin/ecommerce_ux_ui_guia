import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TopNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final VoidCallback? onLeadingPressed;
  final VoidCallback? onActionPressed;
  final IconData leadingIcon;
  final IconData actionIcon;
  final bool showActionIcon;
  final List<Widget>? extraActions;

  const TopNavigationBar({
    super.key,
    this.title = 'Unimet Store',
    this.titleWidget,
    this.onLeadingPressed,
    this.onActionPressed,
    this.leadingIcon = Icons.menu,
    this.actionIcon = Icons.shopping_cart_outlined,
    this.showActionIcon = true,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(leadingIcon, color: AppColors.naranjaUnimet),
            onPressed: onLeadingPressed ?? () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: titleWidget ?? Text(
        title,
        style: theme.textTheme.displayMedium?.copyWith(
          fontSize: 13,
          color: theme.colorScheme.primary,
        ),
      ),
      actions: [
        if (extraActions != null) ...extraActions!,
        if (showActionIcon)
          IconButton(
            icon: Icon(actionIcon, color: AppColors.naranjaUnimet),
            onPressed: onActionPressed,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
