import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'navbar_model.dart';
export 'navbar_model.dart';

import '/widgets/bellion_chat_dialog.dart';
/// Create a reusable Bottom Navigation Bar component for a mobile app.
///
/// Style:
///
/// Similar layout to the Instagram-style navbar in the provided example: 3 to
/// 5 equally spaced icon buttons with labels underneath.
///
/// Background: white with subtle shadow.
///
/// Icons and labels are centered vertically in each tab.
///
/// When a button is active (selected), change the icon and text color to
/// #8ce1dc. Inactive buttons should have gray color (#8a8a8a).
///
/// Use rounded highlight indicator or underline below the active icon (same
/// #8ce1dc color).
///
/// Buttons:
///
/// Map (use a location pin/map icon) with label "Map".
///
/// Minigame (use a game controller or puzzle icon) with label "Minigame".
///
/// Settings (use a gear icon) with label "Settings".
///
/// Functionality:
///
/// Each button should be tappable and navigate to its corresponding page.
///
/// The active state should update visually when the page changes.
///
/// The component should be responsive and reusable across multiple pages.
///
/// Design Notes:
///
/// Keep icons minimal and modern.
///
/// Font: clean sans-serif style.
///
/// Maintain consistent spacing and sizing between icons and labels.

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({
    super.key,
    required this.selectedPageIndex,
    this.hiddne = false,
  });

  final int selectedPageIndex;
  final bool hiddne;

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  late NavbarModel _model;
  bool isChatModalOpen = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

Color getIconColor(int index) {
  if (index == 2 && isChatModalOpen) {
    return const Color(0xFF8CE1DC);
  }
  return widget.selectedPageIndex == index
      ? const Color(0xFF8CE1DC)
      : const Color(0xFF8A8A8A);
}

  void _onTabSelected(int index, String routeName) {
    if (widget.selectedPageIndex == index) return; // Already on this page
    context.pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: double.infinity,
        height: 80.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 8.0,
              color: Color(0x33000000),
              offset: Offset(0.0, -2.0),
              spreadRadius: 0.0,
            )
          ],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Map
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FlutterFlowIconButton(
                    buttonSize: 45.0,
                    icon: Icon(
                      Icons.map,
                      color: getIconColor(0),
                      size: 30.0,
                    ),
                    onPressed: () => _onTabSelected(0, HomepageWidget.routeName),
                  ),
                ].divide(SizedBox(height: 4.0)),
              ),

              // Minigame
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FlutterFlowIconButton(
                    buttonSize: 45.0,
                    icon: Icon(
                      Icons.videogame_asset,
                      color: getIconColor(1),
                      size: 30.0,
                    ),
                    onPressed: () {
                      context.go('/minigame');
                    },
                  ),
                ].divide(SizedBox(height: 4.0)),
              ),

              // Settings
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FlutterFlowIconButton(
                    buttonSize: 45.0,
                    icon: Icon(
                      Icons.settings_sharp,
                      color: getIconColor(3),
                      size: 30.0,
                    ),
                    onPressed: () {
                      context.go('/setting');
                    },
                  ),
                ].divide(SizedBox(height: 4.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}