import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class AgroPlantAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AgroPlantAppBar({
    super.key,
    this.backgroundColor = const Color(0xFFF7F2E8),
    this.foregroundColor = const Color(0xFF174D2A),
    this.title,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.showBackButton = true,
    this.logoWidth = 135,
    this.elevation = 0,
    this.onLogoTap,
    this.fallbackRoute,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool showBackButton;
  final double logoWidth;
  final double elevation;
  final VoidCallback? onLogoTap;
  final String? fallbackRoute;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  void _voltar(BuildContext context) {
    if (fallbackRoute != null) {
      context.go(fallbackRoute!);
      return;
    }

    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leadingWidth: logoWidth,
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onLogoTap ?? (showBackButton ? () => _voltar(context) : null),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 8),
          child: SvgPicture.asset(
            'assets/images/fullLogo.svg',
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
      title: title,
      actions: actions,
      bottom: bottom,
    );
  }
}
