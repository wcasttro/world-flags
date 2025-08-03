import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/country.dart';
import '../models/language.dart';

class CountryService {
  static const String _baseUrl = 'https://restcountries.com/v3.1';

  static Future<List<Country>> getAllCountries([Language? language]) async {
    try {
      final langCode = language?.code ?? 'en';
      final response = await http.get(
        Uri.parse('$_baseUrl/all?fields=name,flags,cca2&lang=$langCode'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Country.fromJson(json)).toList();
      } else {
        inspect(response);
        throw Exception('Falha ao carregar países: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<List<Country>> getRandomCountries(int count,
      [Language? language]) async {
    final allCountries = await getAllCountries(language);
    allCountries.shuffle();
    return allCountries.take(count).toList();
  }
}
