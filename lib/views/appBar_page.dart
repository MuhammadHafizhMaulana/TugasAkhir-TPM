import 'package:flutter/material.dart';

class AppbarPage extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;

  AppbarPage({
    required this.title,
    this.actions,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
        ),
      ),
      backgroundColor: Color(0xFF121212),
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Garamond',
          color: Color(0xFFFFD700),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
