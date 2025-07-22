import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/aqi_provider.dart';
import '../utils/constants.dart';
import 'setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController mapController = MapController();
  int _selectedIndex = 0;

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
      builder: (context) => const _RefreshingDialog(),
    );

    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) Navigator.of(context).pop();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildAQIContent(theme),
          const SettingScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'แผนที่',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
      ),
    );
  }

  Widget _buildAQIContent(ThemeData theme) {
    return Consumer<AQIProvider>(
      builder: (context, aqiProvider, child) {
        LatLng center = provinceCoordinates[aqiProvider.selectedProvince] ??
            LatLng(13.7563, 100.5018);
        final selectedAQI =
            aqiProvider.provinceAQIs[aqiProvider.selectedProvince];

        return Column(
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: aqiProvider.selectedProvince,
                  decoration: InputDecoration(
                    labelText: 'เลือกจังหวัด',
                    labelStyle: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  dropdownColor: theme.cardColor,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  items: thaiProvinces
                      .map((prov) => DropdownMenuItem<String>(
                            value: prov,
                            child: Text(prov),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      aqiProvider.selectedProvince = value;
                      setState(() {
                        final newCenter = provinceCoordinates[value] ??
                            LatLng(13.7563, 100.5018);
                        mapController.move(newCenter, 7);
                      });
                    }
                  },
                ),
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
                        _buildZoomButton(Icons.zoom_in, () {
                          final currentZoom = mapController.camera.zoom;
                          mapController.move(
                              mapController.camera.center, currentZoom + 1);
                        }),
                        const SizedBox(height: 8),
                        _buildZoomButton(Icons.zoom_out, () {
                          final currentZoom = mapController.camera.zoom;
                          mapController.move(
                              mapController.camera.center, currentZoom - 1);
                        }),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        _buildFAB(
                          icon: Icons.refresh,
                          tooltip: 'รีเฟรช AQI ทันที',
                          color: Color(0xFF5BACC3),
                          onTap: () async {
                            _showRefreshingDialog();
                            await aqiProvider.fetchAllProvincesAQI();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('อัปเดตข้อมูล AQI แล้ว'),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildFAB(
                          icon: Icons.info_outline,
                          tooltip: 'ข้อมูลการอัปเดต AQI',
                          color: Colors.blueGrey,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('การอัปเดต AQI'),
                                content: const Text(
                                  'แอปจะอัปเดตค่า AQI อัตโนมัติทุก 5 นาที\n\n'
                                  'AQI (Air Quality Index) คือดัชนีคุณภาพอากาศ\n'
                                  'สามารถกดปุ่มรีเฟรชเพื่ออัปเดตได้ทันทีครับ 😊',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('ปิด'),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                width: double.infinity,
                color: theme.cardColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'จังหวัด: ${aqiProvider.selectedProvince}',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        selectedAQI != null
                            ? 'AQI: $selectedAQI'
                            : 'กำลังโหลดค่า AQI...',
                        key: ValueKey(selectedAQI),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: selectedAQI != null
                              ? getAQIColor(selectedAQI)
                              : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedAQI != null ? getAQIAdvice(selectedAQI) : '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
      mini: true,
      backgroundColor: color,
      tooltip: tooltip,
      onPressed: onTap,
      child: Icon(icon),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      heroTag: icon.toString(),
      mini: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
      child: Icon(icon),
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
