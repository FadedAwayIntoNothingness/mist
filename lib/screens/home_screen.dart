import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/aqi_provider.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AQIProvider>(context, listen: false).startAutoRefresh();
    });
  }

  @override
  void dispose() {
    Provider.of<AQIProvider>(context, listen: false).stopAutoRefresh();
    super.dispose();
  }

  Future<void> _showRefreshingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) {
        return const _RefreshingDialog();
      },
    );

    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('MIST - My Invisible Shield Technology'),
        backgroundColor: const Color.fromARGB(255, 0, 26, 41),
      ),
      body: Consumer<AQIProvider>(
        builder: (context, aqiProvider, child) {
          LatLng center = provinceCoordinates[aqiProvider.selectedProvince] ??
              LatLng(13.7563, 100.5018);

          final selectedAQI = aqiProvider.provinceAQIs[aqiProvider.selectedProvince];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.black87,
                  value: aqiProvider.selectedProvince,
                  decoration: InputDecoration(
                    labelText: 'เลือกจังหวัด',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mistBlue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  items: thaiProvinces
                      .map((prov) => DropdownMenuItem<String>(
                            value: prov,
                            child: Text(prov),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      aqiProvider.selectedProvince = value;
                      setState(() {});
                      final newCenter =
                          provinceCoordinates[value] ?? LatLng(13.7563, 100.5018);
                      mapController.move(newCenter, 7);
                    }
                  },
                ),
              ),
              Expanded(
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
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.mist_aqi',
                        ),
                        MarkerLayer(
                          markers: aqiProvider.aqiMarkers,
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'zoom_in',
                            mini: true,
                            backgroundColor: Colors.black,
                            onPressed: () {
                              final currentZoom = mapController.camera.zoom;
                              mapController.move(
                                  mapController.camera.center, currentZoom + 1);
                            },
                            child: const Icon(Icons.zoom_in),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'zoom_out',
                            mini: true,
                            backgroundColor: Colors.black,
                            onPressed: () {
                              final currentZoom = mapController.camera.zoom;
                              mapController.move(
                                  mapController.camera.center, currentZoom - 1);
                            },
                            child: const Icon(Icons.zoom_out),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'refresh_aqi',
                            mini: true,
                            backgroundColor: Colors.green.shade800,
                            tooltip: 'รีเฟรช AQI ทันที',
                            onPressed: () async {
                              _showRefreshingDialog();
                              await aqiProvider.fetchAllProvincesAQI();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('อัปเดตข้อมูล AQI แล้ว'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            },
                            child: const Icon(Icons.refresh),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'info_aqi',
                            mini: true,
                            backgroundColor: Colors.blueGrey,
                            tooltip: 'ข้อมูลการอัปเดต AQI',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('การอัปเดต AQI'),
                                  content: const Text(
                                    'แอปจะอัปเดตค่า AQI อัตโนมัติทุก 5 นาที\n'
                                    '(AQI คือ Air Quality Index หรือดัชนีคุณภาพอากาศ)\n'
                                    'หากคุณต้องการข้อมูลล่าสุดทันที\n'
                                    'สามารถกดปุ่มรีเฟรชได้เลยครับ 😊',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('ปิด'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Icon(Icons.info_outline),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'จังหวัด: ${aqiProvider.selectedProvince}',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedAQI != null
                          ? 'AQI: $selectedAQI'
                          : 'กำลังโหลดค่า AQI...',
                      style: TextStyle(
                        color: selectedAQI != null
                            ? getAQIColor(selectedAQI)
                            : Colors.white54,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedAQI != null ? getAQIAdvice(selectedAQI) : '',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RefreshingDialog extends StatelessWidget {
  const _RefreshingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            Container(
              width: size.width,
              height: size.height,
              color: Colors.black45,
            ),
            Center(
              child: Image.asset(
                'assets/loading.gif',
                width: 300,
                height: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
