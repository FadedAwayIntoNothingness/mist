import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIST Prototype',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MyHomePage(title: 'MIST Prototype'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController =
      MapController(); // Controller for moving the map camera

  late LatLng _markerPosition; // Holds the current marker's latlong
  String aqiResult =
      ''; // Store the text AQI result that return from the API call

  String?
  selectedProvince; // The province selected by the user from the dropdown

  //Province list for the dropdown list
  static const List<String> thaiProvinces = [
    'Bangkok',
    'Krabi',
    'Kanchanaburi',
    'Kalasin',
    'Kamphaeng Phet',
    'Khon Kaen',
    'Chanthaburi',
    'Chachoengsao',
    'Chonburi',
    'Chai Nat',
    'Chaiyaphum',
    'Chumphon',
    'Chiang Rai',
    'Chiang Mai',
    'Trang',
    'Trat',
    'Tak',
    'Nakhon Nayok',
    'Nakhon Pathom',
    'Nakhon Phanom',
    'Nakhon Ratchasima',
    'Nakhon Si Thammarat',
    'Nakhon Sawan',
    'Nonthaburi',
    'Narathiwat',
    'Nan',
    'Bueng Kan',
    'Buri Ram',
    'Pathum Thani',
    'Prachuap Khiri Khan',
    'Prachinburi',
    'Pattani',
    'Phra Nakhon Si Ayutthaya',
    'Phayao',
    'Phang Nga',
    'Phatthalung',
    'Phichit',
    'Phitsanulok',
    'Phetchaburi',
    'Phetchabun',
    'Phrae',
    'Phuket',
    'Maha Sarakham',
    'Mukdahan',
    'Mae Hong Son',
    'Yasothon',
    'Yala',
    'Roi Et',
    'Ranong',
    'Rayong',
    'Ratchaburi',
    'Lopburi',
    'Lampang',
    'Lamphun',
    'Loei',
    'Si Sa Ket',
    'Sakon Nakhon',
    'Songkhla',
    'Satun',
    'Samut Prakan',
    'Samut Songkhram',
    'Samut Sakhon',
    'Sa Kaeo',
    'Saraburi',
    'Sing Buri',
    'Sukhothai',
    'Suphan Buri',
    'Surat Thani',
    'Surin',
    'Nong Khai',
    'Nong Bua Lamphu',
    'Amnat Charoen',
    'Udon Thani',
    'Uttaradit',
    'Uthai Thani',
    'Ubon Ratchathani',
  ];

  //coordinatemap; connect the province to the latlong
  final Map<String, LatLng> provinceCoordinates = {
    'Bangkok': LatLng(13.7563, 100.5018),
    'Krabi': LatLng(8.0863, 98.9063),
    'Kanchanaburi': LatLng(14.0206, 99.5326),
    'Kalasin': LatLng(16.4379, 103.5003),
    'Kamphaeng Phet': LatLng(16.4827, 99.5206),
    'Khon Kaen': LatLng(16.4419, 102.8356),
    'Chanthaburi': LatLng(12.6131, 102.0383),
    'Chachoengsao': LatLng(13.6874, 101.0637),
    'Chonburi': LatLng(13.3611, 100.9847),
    'Chai Nat': LatLng(15.1853, 100.1225),
    'Chaiyaphum': LatLng(15.8077, 102.0354),
    'Chumphon': LatLng(10.4930, 99.1800),
    'Chiang Rai': LatLng(19.9075, 99.8324),
    'Chiang Mai': LatLng(18.7883, 98.9853),
    'Trang': LatLng(7.5681, 99.6143),
    'Trat': LatLng(12.2435, 102.5159),
    'Tak': LatLng(16.8731, 98.6140),
    'Nakhon Nayok': LatLng(14.2089, 101.2130),
    'Nakhon Pathom': LatLng(13.8214, 100.0447),
    'Nakhon Phanom': LatLng(17.4009, 104.7881),
    'Nakhon Ratchasima': LatLng(14.9799, 102.0977),
    'Nakhon Si Thammarat': LatLng(8.4388, 99.9636),
    'Nakhon Sawan': LatLng(15.6984, 100.1220),
    'Nonthaburi': LatLng(13.8628, 100.5144),
    'Narathiwat': LatLng(6.4243, 101.8162),
    'Nan': LatLng(18.7877, 100.7738),
    'Bueng Kan': LatLng(17.8325, 103.6405),
    'Buri Ram': LatLng(14.9932, 103.1005),
    'Pathum Thani': LatLng(14.0200, 100.5250),
    'Prachuap Khiri Khan': LatLng(11.8091, 99.7764),
    'Prachinburi': LatLng(14.0375, 101.3869),
    'Pattani': LatLng(6.8697, 101.2501),
    'Phra Nakhon Si Ayutthaya': LatLng(14.3531, 100.5687),
    'Phayao': LatLng(19.1600, 99.8867),
    'Phang Nga': LatLng(8.4500, 98.5333),
    'Phatthalung': LatLng(7.6175, 100.0801),
    'Phichit': LatLng(16.4286, 100.3542),
    'Phitsanulok': LatLng(16.8213, 100.2654),
    'Phetchaburi': LatLng(13.1109, 99.8016),
    'Phetchabun': LatLng(16.4000, 101.1500),
    'Phrae': LatLng(18.1461, 100.1408),
    'Phuket': LatLng(7.8804, 98.3923),
    'Maha Sarakham': LatLng(16.1744, 103.2931),
    'Mukdahan': LatLng(16.5451, 104.7239),
    'Mae Hong Son': LatLng(19.3011, 97.9677),
    'Yasothon': LatLng(15.8079, 104.1431),
    'Yala': LatLng(6.5390, 101.2801),
    'Roi Et': LatLng(16.0542, 103.6524),
    'Ranong': LatLng(9.9585, 98.6340),
    'Rayong': LatLng(12.6819, 101.2801),
    'Ratchaburi': LatLng(13.5250, 99.8180),
    'Lopburi': LatLng(14.7998, 100.6514),
    'Lampang': LatLng(18.2885, 99.4875),
    'Lamphun': LatLng(18.5733, 99.0100),
    'Loei': LatLng(17.4803, 101.7215),
    'Si Sa Ket': LatLng(14.7799, 104.0416),
    'Sakon Nakhon': LatLng(17.1695, 104.1411),
    'Songkhla': LatLng(7.2009, 100.5955),
    'Satun': LatLng(6.6235, 100.0675),
    'Samut Prakan': LatLng(13.5997, 100.5997),
    'Samut Songkhram': LatLng(13.4171, 100.0000),
    'Samut Sakhon': LatLng(13.5435, 100.2226),
    'Sa Kaeo': LatLng(13.8740, 102.0823),
    'Saraburi': LatLng(14.4446, 100.9163),
    'Sing Buri': LatLng(15.1819, 100.4030),
    'Sukhothai': LatLng(17.0049, 99.8207),
    'Suphan Buri': LatLng(14.4741, 100.1133),
    'Surat Thani': LatLng(9.1382, 99.3332),
    'Surin': LatLng(14.8828, 103.4939),
    'Nong Khai': LatLng(17.8786, 102.7884),
    'Nong Bua Lamphu': LatLng(17.3287, 102.4438),
    'Amnat Charoen': LatLng(15.7569, 104.6084),
    'Udon Thani': LatLng(17.4120, 102.7856),
    'Uttaradit': LatLng(17.4084, 100.0286),
    'Uthai Thani': LatLng(15.2999, 99.4562),
    'Ubon Ratchathani': LatLng(15.2449, 104.8481),
  };

  @override
  void initState() {
    super.initState();
    selectedProvince = 'Bangkok';
    _markerPosition =
        provinceCoordinates['Bangkok']!; // make the default marker location be Bangkok (for now) + fetch for the base API (Bangkok or the user location)
    _fetchAndShowAQI(
      _markerPosition.latitude,
      _markerPosition.longitude,
    ); // fetch first AQI for Bangkok (default location)
  }

  // Fetch AQI from the API, move the map, and set aqiResult
  Future<void> _fetchAndShowAQI(double lat, double lon) async {
    _mapController.move(LatLng(lat, lon), 10.0);

    final token =
        '7b2ed38ad4ad1782e0305c54968283fb202085ee'; //token for access to API
    final url =
        'https://api.waqi.info/feed/geo:$lat;$lon/?token=$token'; // URL for fetch info from AQI

    try {
      final resp = await http.get(Uri.parse(url)); // fetch info from API
      final data = json.decode(resp.body); // decode json to dart object

      if (resp.statusCode == 200 && data['status'] == 'ok') {
        final city = selectedProvince!;
        final aqi = data['data']['aqi'];
        aqiResult = '$city\nAQI: $aqi';
      } else {
        aqiResult = 'Error: ${data['status']}';
      }
    } catch (e) {
      aqiResult = 'Exception: $e';
    }

    setState(() {}); // Refresh the screen to show new data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16), //padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Province Dropdown list
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Province',
                hintText: 'Select Province',
              ),
              items: thaiProvinces
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(), // create the dropdown items
              value: selectedProvince,
              onChanged: (v) {
                selectedProvince = v; // save selected province
                final coord =
                    provinceCoordinates[v!]!; // get province coordinates
                _fetchAndShowAQI(
                  coord.latitude,
                  coord.longitude,
                ); // then fetch AQI
              },
            ),

            const SizedBox(
              height: 24,
            ), // space between the dropdown list and AQI result

            Text(
              aqiResult,
              style: const TextStyle(fontSize: 18),
            ), // AQI result and the style

            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _markerPosition,
                  zoom: 10.0,
                ), // set map view
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _markerPosition,
                        width: 40,
                        height: 40,
                        builder: (ctx) => const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
