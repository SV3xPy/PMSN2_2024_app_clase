import 'package:dio/dio.dart';
import 'package:app_clase/models/popular_movie.dart';

class ApiPopular {
  final URL =
      "https://api.themoviedb.org/3/movie/popular?api_key=7b217eff129625c9d831ceb45f4d3c58&language=es-MX";
  final dio = Dio();
  Future<List<PopularModel>?> getPopularMovie() async {
    Response response = await dio.get(URL);
    if (response.statusCode == 200) {
      final listMoviesMap = response.data['results'] as List;
      return listMoviesMap.map((movie) => PopularModel.fromMap(movie)).toList();
    }
    return null;
  }

  Future<PopularModel?> getMovieDetails(int movieId) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.themoviedb.org/3/movie/$movieId?api_key=558a6043ffaf21488d74cb6f44181b9a&language=es-MX',
      );

      if (response.statusCode == 200) {
        return PopularModel.fromMap(response
            .data); // Crear un objeto PopularModel desde los datos de la respuesta
      } else {
        throw Exception('Failed to retrieve movie details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
