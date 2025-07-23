import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/aqi_provider.dart';
import '../utils/constants.dart';
import 'setting_screen.dart';
import 'minigame_screen.dart';
import '../widgets/bellion_chat_dialog.dart';

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

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildAQIContent(theme),
          const MinigameScreen(),
          const SettingScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'แผนที่'),
          BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'มินิเกม'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ตั้งค่า'),
        ],
      ),
    );
  }

  Widget _buildAQIContent(ThemeData theme) {
    return Consumer<AQIProvider>(
      builder: (context, aqiProvider, child) {
        final center = provinceCoordinates[aqiProvider.selectedProvince] ?? const LatLng(13.7563, 100.5018);
        final selectedAQI = aqiProvider.provinceAQIs[aqiProvider.selectedProvince];

        return Stack(
          children: [
            Column(
              children: [
                // จังหวัด Dropdown
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      value: aqiProvider.selectedProvince,
                      decoration: InputDecoration(
                        labelText: 'เลือกจังหวัด',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: thaiProvinces
                          .map((prov) => DropdownMenuItem<String>(value: prov, child: Text(prov)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          aqiProvider.selectedProvince = value;
                          setState(() {
                            final newCenter = provinceCoordinates[value] ?? const LatLng(13.7563, 100.5018);
                            mapController.move(newCenter, 7);
                          });
                        }
                      },
                    ),
                  ),
                ),

                // แผนที่
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

                      // ปุ่ม Zoom
                      Positioned(
                        bottom: 16,
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

                      // ปุ่ม FAB ขวาบน
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Column(
                          children: [
                            _buildFAB(
                              icon: Icons.refresh,
                              tooltip: 'รีเฟรช AQI',
                              color: const Color(0xFF5BACC3),
                              onTap: () async {
                                _showRefreshingDialog();
                                await aqiProvider.fetchAllProvincesAQI();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('อัปเดตข้อมูล AQI แล้ว')),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildFAB(
                              icon: Icons.info_outline,
                              tooltip: 'ข้อมูล AQI',
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
                                        onPressed: () => Navigator.of(context).pop(),
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

                // แสดง AQI ด้านล่าง
                Container(
                  width: double.infinity,
                  color: theme.cardColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          selectedAQI != null ? 'AQI: $selectedAQI' : 'กำลังโหลดค่า AQI...',
                          key: ValueKey(selectedAQI),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: selectedAQI != null ? getAQIColor(selectedAQI) : Colors.grey,
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
              ],
            ),
            _buildChatHead(),
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

  Widget _buildChatHead() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const BellionChatDialog(),
          );
        },
        child: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blueAccent,
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
            Container(width: size.width, height: size.height, color: Colors.black45),
            Center(
              child: Image.asset('assets/loading.gif', width: 300, height: 300),
            ),
          ],
        ),
      ),
    );
  }
}
