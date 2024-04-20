import 'package:app_clase/models/popular_movie.dart';
import 'package:flutter/material.dart';
import 'package:app_clase/network/api_favorite.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  const FavoriteMoviesScreen({super.key});

  @override
  State<FavoriteMoviesScreen> createState() => _FavoriteMoviesScreenState();
}

class _FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  final ApiFavorites apiFavorites = ApiFavorites();
  // Future<List<PopularModel>>? _favoriteMoviesFuture;
  @override
  void initState() {
    super.initState();
    apiFavorites.getFavoriteMoviesStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 7, 30),
        title: const Text(
          'Películas Favoritas',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 1, 7, 30),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: apiFavorites.favoriteMoviesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay películas favoritas'));
          } else {
            // Convierte cada mapa en un objeto PopularModel
            final favoriteMovies = snapshot.data!
                .map((movie) => PopularModel.fromJson(movie))
                .toList();
            return GridView.builder(
              itemCount: snapshot.data!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/detail",
                      arguments: favoriteMovies[index]),
                  child: Hero(
                    tag: 'poster_${snapshot.data![index]['id']}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FadeInImage(
                        placeholder: const AssetImage('images/load.gif'),
                        image: NetworkImage(
                            'https://image.tmdb.org/t/p/w500/${snapshot.data![index]['poster_path']}'),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
