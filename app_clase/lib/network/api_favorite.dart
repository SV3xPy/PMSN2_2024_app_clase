import 'dart:async';

import 'package:app_clase/models/popular_movie.dart';
import 'package:dio/dio.dart';

class ApiFavorites {
  final String apiKey = '7b217eff129625c9d831ceb45f4d3c58';
  final String sessionId =
      '2227dcda4e521fd3507f7f90f5c3dd6c570da33a'; // Session ID existente
  final String authorizedRequestToken =
      '7ccd88d03792ff8c5a7c2826388a00fc7713d9b9';
  final String accountId = '21050746';
  final StreamController<List<Map<String, dynamic>>>
      _favoriteMoviesStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get favoriteMoviesStream =>
      _favoriteMoviesStreamController.stream;
  //Se nos pemitira el tener la lista de las peliculas favoritas de la sesion y cuenta
  Future<List<Map<String, dynamic>>> getFavoriteMovies() async {
    try {
      //final sessionData = await getSessionData();
      //final sessionId = sessionData['sessionId'];
      //print('"Sesion: "$sessionId');
      //final accountId = sessionData['accountId'];

      final dio = Dio();
      final response = await dio.get(
        'https://api.themoviedb.org/3/account/$accountId/favorite/movies',
        queryParameters: {
          'api_key': apiKey,
          'session_id': sessionId,
        },
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> favoriteMovies =
            List<Map<String, dynamic>>.from(response.data['results']);
        return favoriteMovies;
      } else {
        throw Exception('Failed to retrieve favorite movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> getFavoriteMoviesStream() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.themoviedb.org/3/account/$accountId/favorite/movies',
        queryParameters: {
          'api_key': apiKey,
          'session_id': sessionId,
        },
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> favoriteMovies =
            List<Map<String, dynamic>>.from(response.data['results']);
        _favoriteMoviesStreamController.add(favoriteMovies);
      } else {
        throw Exception('Failed to retrieve favorite movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //Funcion para dar de alta una nueva pelicula favorita
  Future<void> addToFavorites(int movieId) async {
    try {
      //  final sessionData = await getSessionData();
      // final sessionId = sessionData['sessionId'];
      final dio = Dio();
      final response = await dio.post(
        'https://api.themoviedb.org/3/account/$accountId/favorite',
        queryParameters: {
          'api_key': apiKey,
          'session_id': sessionId,
        },
        data: {
          'media_type': 'movie',
          'media_id': movieId,
          'favorite': true,
        },
      );

      if (response.statusCode == 200) {
        print('Película agregada a favoritos');
      } else {
        print('Error al agregar la película a favoritos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  //Funcion para quitar de favoritos
  Future<void> removeFromFavorites(int movieId) async {
    try {
      //final sessionData = await getSessionData();
      //final sessionId = sessionData['sessionId'];
      final dio = Dio();
      final response = await dio.post(
        'https://api.themoviedb.org/3/account/$accountId/favorite',
        queryParameters: {
          'api_key': apiKey,
          'session_id': sessionId,
        },
        data: {
          'media_type': 'movie',
          'media_id': movieId,
          'favorite': false,
        },
      );
      print('"Estatus: " $response.statusCode');
      if (response.statusCode == 200) {
        print('Película eliminada de favoritos');
      } else {
        print('Error al eliminar la película de favoritos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  //No tendria sentido editar un favorito asi que
  //omite el actualizar.
  Future<PopularModel?> getMovieDetails(int movieId) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=es-MX',
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
