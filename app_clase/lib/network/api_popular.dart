
import 'package:dio/dio.dart';
import 'package:app_clase/models/popular_movie.dart';
class ApiPopular{
  final URL = "https://api.themoviedb.org/3/movie/popular?api_key=7b217eff129625c9d831ceb45f4d3c58&language=es-MX&page=1";
  final dio = Dio();
  Future<List<PopularModel>?> getPopularMovie()async{
    Response response = await dio.get(URL);
    if(response.statusCode == 200){
      final listMoviesMap = response.data['results'] as List;
      return listMoviesMap.map((movie)=> PopularModel.fromMap(movie)).toList();
    }
    return null;
  }
}