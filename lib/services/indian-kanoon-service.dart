import 'package:http/http.dart' as http;
import 'dart:convert';

class IndianKanoonService {
  final String baseUrl = "https://api.indiankanoon.org/";
  final String authToken = "7c7dd7090ed8a1461a6e08f959e9a46c4c0427ee";
  final Map<String, String> headers;

  IndianKanoonService()
      : headers = {
          'authorization': "Token 7c7dd7090ed8a1461a6e08f959e9a46c4c0427ee",
          'cache-control': "no-cache",
        };

  Future<List<dynamic>> searchLegalNews({String query = 'recent judgment supreme court high court'}) async {
    final url = Uri.parse('${baseUrl}search/');
    
    final params = {
      'formInput': query,
      'pagenum': '0',
    };
    
    final response = await http.post(
      url.replace(queryParameters: params),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('docs')) {
        return data['docs'];
      }
      return [];
    } else {
      throw Exception('Failed to search: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getDoc(String docid) async {
    final url = Uri.parse('${baseUrl}doc/$docid/');
    
    final response = await http.post(
      url,
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get document: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getDocMeta(String docid) async {
    final url = Uri.parse('${baseUrl}docmeta/$docid/');
    
    final response = await http.post(
      url,
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get document metadata: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> getDocFragment(String docid, String query) async {
    final url = Uri.parse('${baseUrl}docfragment/$docid/');
    
    final params = {
      'formInput': query,
    };
    
    final response = await http.post(
      url.replace(queryParameters: params),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get document fragment: ${response.statusCode}');
    }
  }
}
