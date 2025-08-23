import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'homepage_model.dart';
export 'homepage_model.dart';

import '/utils/constants.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '/providers/aqi_provider.dart';
import '/widgets/bellion_chat_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class HomepageWidget extends StatefulWidget {
  const HomepageWidget({super.key});

  static String routeName = 'Homepage';
  static String routePath = '/homepage';

  @override
  State<HomepageWidget> createState() => _HomepageWidgetState();
}

class _HomepageWidgetState extends State<HomepageWidget> {
  late HomepageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late final MapController mapController;
  final latlong.LatLng center = latlong.LatLng(13.736717, 100.523186); // Example: Bangkok
  late AQIProvider aqiProvider;

@override
void initState() {
  super.initState();
  _model = createModel(context, () => HomepageModel());
  mapController = MapController();
  aqiProvider = Provider.of<AQIProvider>(context, listen: false);

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _model.fetchAQIForProvince('Bangkok');
    setState(() {}); // Update UI after fetching
    await _askLocationPermission();
  });
}

  Future<void> _askLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isGranted || status.isPermanentlyDenied) {
    // Already handled, do nothing
    return;
  }
  var result = await Permission.location.request();
  if (result.isGranted) {
    print('✅ Location permission granted');
  } else {
    print('❌ Location permission denied');
    // Optionally show a dialog to explain why you need location
  }
}

Widget _buildZoomButton(IconData icon, VoidCallback onTap) {
  return FloatingActionButton(
    mini: true,
    onPressed: onTap,
    child: Icon(icon),
  );
}

Widget _buildFAB({
  required IconData icon,
  required String tooltip,
  required Color color,
  required VoidCallback onTap,
}) {
  return FloatingActionButton(
    heroTag: tooltip,
    backgroundColor: color,
    onPressed: onTap,
    child: Icon(icon),
    tooltip: tooltip,
  );
}

void _showRefreshingDialog() {
  showDialog(
    context: context,
    builder: (_) => const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Refreshing AQI...'),
        ],
      ),
    ),
  );
}

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final aqiProvider = Provider.of<AQIProvider>(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // ...existing code...

            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 7,
                      minZoom: 5,
                      maxZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        tileProvider: NetworkTileProvider(
                          headers: {
                            'User-Agent': 'FlutterAQIApp/1.0 (viktor.pongpisut@gmail.com)',
                          },
                        ),
                      ),
                      MarkerLayer(markers: aqiProvider.aqiMarkers),
                    ],
                  ),

                  // Zoom buttons
                  Positioned(
                    bottom: 365,
                    right: 16,
                    child: Column(
                      children: [
                        _buildZoomButton(Icons.zoom_in, () {
                          mapController.move(
                            mapController.camera.center,
                            mapController.camera.zoom + 1,
                          );
                        }),
                        const SizedBox(height: 8),
                        _buildZoomButton(Icons.zoom_out, () {
                          mapController.move(
                            mapController.camera.center,
                            mapController.camera.zoom - 1,
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  // Bellion chat head (below the zoom buttons)
                  Positioned(
                    bottom: 305, // Adjust this value to place it under the zoom buttons
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.95,
                            child: BellionChatDialog(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.greenAccent,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/aipfp.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // FABs
                  Positioned(
                    top: 100,
                    right: 16,
                    child: Column(
                      children: [
                        _buildFAB(
                          icon: Icons.refresh,
                          tooltip: 'refresh AQI',
                          color: const Color(0xFF5BACC3),
                          onTap: () async {
                            _showRefreshingDialog();
                            await aqiProvider.fetchAllProvincesAQI();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('AQI data updated')),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildFAB(
                          icon: Icons.info_outline,
                          tooltip: 'AQI Data',
                          color: Colors.blueGrey,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('AQI Update'),
                                content: const Text(
                                  'The app will automatically update the AQI value every 5 minutes\n\n'
                                  'AQI (Air Quality Index) is an indicator of air quality\n'
                                  'You can also press the refresh button to update immediately 😊',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 35.0, 24.0, 16.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0x80FFFFFF),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, -1.0),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FlutterFlowDropDown<String>(
                                  controller: _model.dropDownValueController ??=
                                      FormFieldController<String>(
                                    _model.dropDownValue ??= 'Bangkok',
                                  ),
                                  options: thaiProvinces,

                                  onChanged: (val) async {
                                    safeSetState(() => _model.dropDownValue = val);
                                    await _model.fetchAQIForProvince(val!);
                                  },
                                  width: 300.0,
                                  height: 40.0,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  hintText: 'Select City',
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 20.0,
                                  ),
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  elevation: 2.0,
                                  borderColor: Colors.transparent,
                                  borderWidth: 0.0,
                                  borderRadius: 20.0,
                                  margin: EdgeInsetsDirectional.fromSTEB(
                                      20.0, 4.0, 8.0, 4.0),
                                  hidesUnderline: true,
                                  isSearchable: false,
                                  isMultiSelect: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 24.0, 24.0, 90.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0,
                              color: Color(0x40000000),
                              offset: Offset(
                                0.0,
                                5.0,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 24.0,
                                  ),
                                  Text(
                                     _model.dropDownValue ?? 'Bangkok',
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleLarge
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 22.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleLarge
                                                  .fontStyle,
                                        ),
                                  ),
                                ].divide(SizedBox(width: 8.0)),
                              ),
                              Container(
                                width: 80.0,
                                height: 80.0,
                                decoration: BoxDecoration(
                                  color: getAQIColor(_model.aqiValue ?? 0),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 15.0,
                                      color: Color(0x4027AE60),
                                    )
                                  ],
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _model.aqiValue?.toString() ?? '-',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .displayMedium
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .displayMedium
                                                        .fontStyle,
                                              ),
                                              color: Colors.white,
                                              fontSize: 25.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .displayMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Text(
                                        'AQI',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                              color: Colors.white,
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontStyle,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      getAQIAdvice(_model.aqiValue),
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall // Use a smaller text style
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .fontStyle,
                                            ),
                                            color: const Color.fromARGB(255, 145, 143, 143),
                                            fontSize: 15.0, // Smaller font size
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),

                                ].divide(SizedBox(height: 8.0)),
                              ),
                            ].divide(SizedBox(height: 16.0)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.navbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: NavbarWidget(selectedPageIndex: 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
