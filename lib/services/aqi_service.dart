import 'dart:convert';
import 'package:http/http.dart' as http;

class AqiService {
  static const String _token = '7b2ed38ad4ad1782e0305c54968283fb202085ee';

  Future<int?> fetchCurrentAQI(double lat, double lon) async {
    try {
      final url = Uri.parse('https://api.waqi.info/feed/geo:$lat;$lon/?token=$_token');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok' && data['data']?['aqi'] != null) {
          return data['data']['aqi'] as int;
        }
      }
    } catch (e) {
      print('Exception: $e');
    }
    return null;
  }
}