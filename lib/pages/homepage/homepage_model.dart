import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'homepage_widget.dart' show HomepageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/services/aqi_service.dart'; 
import '/utils/constants.dart';

class HomepageModel extends FlutterFlowModel<HomepageWidget> {
  ///  State fields for stateful widgets in this page.

  // Method to fetch AQI for a selected province
  Future<void> fetchAQIForProvince(String province) async {
    final coords = provinceCoordinates[province];
    if (coords == null) return;

    final fetchedAQI = await AqiService().fetchCurrentAQI(coords.latitude, coords.longitude);
    aqiValue = fetchedAQI;
    // No notifyListeners() needed here
  }
  
  // State field(s) for DropDown widget.
  String? dropDownValue = 'Bangkok'; // Default value

  FormFieldController<String>? dropDownValueController;

  // Field to store AQI value
  int? aqiValue;

  // Model for Navbar component.
  late NavbarModel navbarModel;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    navbarModel.dispose();
  }
}