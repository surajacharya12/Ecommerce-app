import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

final String _baseUrl = API_URL;
const String _posterEndpoint = '/posters';

class PosterService {
  Future<List<Map<String, dynamic>>> fetchAllPosters() async {
    final uri = Uri.parse('$_baseUrl$_posterEndpoint');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> postersData = responseData['data'];
          return postersData.cast<Map<String, dynamic>>();
        } else {
          throw Exception(
            responseData['message'] ??
                'Failed to load posters: API reported failure.',
          );
        }
      } else {
        throw Exception(
          'Failed to load posters. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching posters: $e');
      rethrow;
    }
  }
}

class Poster {
  final String id;
  final String posterName;
  final String imageUrl;
  final String subText;

  Poster({
    required this.id,
    required this.posterName,
    required this.imageUrl,
    required this.subText,
  });

  factory Poster.fromJson(Map<String, dynamic> json) {
    return Poster(
      id: json['_id'] ?? '',
      posterName: json['posterName'] ?? 'Special Offer',
      imageUrl: json['imageUrl'] ?? 'no_url',
      subText: json['subText'] ?? 'Up to 40% Off!',
    );
  }
}
