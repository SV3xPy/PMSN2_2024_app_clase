//import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';

class MovieCastFetcher {
  static const String apiKey =
      '7b217eff129625c9d831ceb45f4d3c58'; // Reemplaza con tu clave de API
  static const String baseUrl = 'https://api.themoviedb.org/3/movie/';
  final Dio _dio = Dio();
  Future<List<String>> getCast(int movieId) async {
    List<String> cast = [];
    final response = await _dio.get('$baseUrl$movieId/credits?api_key=$apiKey');

    if (response.statusCode == 200) {
      var data = response.data;
      var results = data['cast'];
      for (var actor in results) {
        if (actor['order'] <= 5) {
          // Puedes ajustar este número para mostrar más o menos actores
          cast.add('${actor['name']} como ${actor['character']}');
        }
      }
    } else {
      throw Exception('Failed to load cast.');
    }
    return cast;
  }

  Future<List<String>> getReviews(int movieId) async {
    List<String> reviews = [];
    final response = await _dio.get('$baseUrl$movieId/reviews?api_key=$apiKey');

    if (response.statusCode == 200) {
      var data = response.data;
      var results = data['results'];
      for (var review in results) {
        reviews.add('${review['author']}: ${review['content']}');
      }
    } else {
      throw Exception('Failed to load reviews.');
    }
    return reviews;
  }

/*
  Future<Map<String, dynamic>> getProviders(int movieId) async {
    Map<String, dynamic> providers = {};
    final response = await http
        .get(Uri.parse('$baseUrl$movieId/watch/providers?api_key=$apiKey'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        providers = data['results'];
      }
    } else {
      throw Exception('Failed to load providers.');
    }
    return providers;
  }
*/
  Future<List<Map<String, dynamic>>> getSuggestions(int movieId) async {
    final response = await _dio.get('$baseUrl$movieId/similar?api_key=$apiKey');

    if (response.statusCode == 200) {
      var data = response.data;
      if (data['results'] != null && data['results'].isNotEmpty) {
        // Ordena los resultados para asegurar una selección aleatoria
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(data['results']);
        results.shuffle(
            Random()); // Desordena los resultados para seleccionar aleatoriamente

        // Selecciona 5 películas aleatorias
        List<Map<String, dynamic>> selectedMovies = results.take(5).toList();

        //Extrae el original_title y poster_path de cada película seleccionada
        List<Map<String, dynamic>> movieSuggestions =
            selectedMovies.map((movie) {
          return {
            'original_title': movie['original_title'],
            'poster_path': movie['poster_path'],
          };
        }).toList();

        return movieSuggestions;
      } else {
        throw Exception('No se encontraron resultados.');
      }
    } else {
      throw Exception('Error al cargar las sugerencias.');
    }
  }
}
