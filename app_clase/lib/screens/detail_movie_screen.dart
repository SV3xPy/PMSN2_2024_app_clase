import 'dart:ui';

import 'package:app_clase/models/popular_movie.dart';
import 'package:app_clase/network/api_actors.dart';
import 'package:flutter/material.dart';
import 'package:app_clase/network/api_trailer.dart';
import 'package:app_clase/network/api_favorite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailMovieScreen extends StatefulWidget {
  const DetailMovieScreen({super.key});

  @override
  State<DetailMovieScreen> createState() => _DetailMovieScreenState();
}

class _DetailMovieScreenState extends State<DetailMovieScreen> {
  late YoutubePlayerController _controller;
  bool isLoading = true;
  bool isFavorite = false;
  final ApiFavorites apiFavorites = ApiFavorites();
  Key favoriteKey = UniqueKey();
  List<String> cast = [];
  List<String> reviews = [];
  List<String> suggestions = [];
  bool showReviews = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTrailer();
    _checkIsFavorite();
    _loadCast();
    _loadReviews();
    _loadSuggestions();
  }

  void _loadTrailer() async {
    final popularModel =
        ModalRoute.of(context)!.settings.arguments as PopularModel;
    final trailerFetcher = MovieTrailerFetcher();
    try {
      final trailers = await trailerFetcher.getTrailers(popularModel.id!);
      if (trailers.isNotEmpty) {
        final trailerId = YoutubePlayer.convertUrlToId(trailers[0]);
        if (trailerId != null) {
          setState(() {
            _controller = YoutubePlayerController(
              initialVideoId: trailerId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
              ),
            );
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'Error cargando el trailer de $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // Función para verificar si la película ya está en la lista de favoritos
  void _toggleFavorite() async {
    final popularModel =
        ModalRoute.of(context)!.settings.arguments as PopularModel;
    try {
      if (isFavorite) {
        await apiFavorites.removeFromFavorites(popularModel.id!);
        setState(() {
          isFavorite = false;
        });
      } else {
        await apiFavorites.addToFavorites(popularModel.id!);
        setState(() {
          isFavorite = true;
        });
      }
      // Después de agregar o eliminar la película de favoritos, cambia la clave para forzar la reconstrucción
      setState(() {
        favoriteKey = UniqueKey();
      });
      // Asegúrate de llamar a _checkIsFavorite después de agregar a favoritos para actualizar el estado
      _checkIsFavorite();
    } catch (e) {
      print('Error: $e');
    }
  }

  // Función para verificar si la película ya está en la lista de favoritos
  void _checkIsFavorite() async {
    final popularModel =
        ModalRoute.of(context)!.settings.arguments as PopularModel;
    try {
      final favoriteMovies = await apiFavorites.getFavoriteMovies();
      setState(() {
        isFavorite =
            favoriteMovies.any((movie) => movie['id'] == popularModel.id);
      });
    } catch (e) {
      print('Error al verificar si la película está en favoritos: $e');
    }
  }

  void _loadCast() async {
    final popularModel =
        ModalRoute.of(context)!.settings.arguments as PopularModel;
    final castFetcher = MovieCastFetcher();
    try {
      cast = await castFetcher.getCast(popularModel.id!);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error cargando el reparto de $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<List<Map<String, dynamic>>> _loadSuggestions() async {
    final popularModel =
        ModalRoute.of(context)!.settings.arguments as PopularModel;
    final suggestionFetcher = MovieCastFetcher();
    try {
      List<Map<String, dynamic>> suggestions =
          await suggestionFetcher.getSuggestions(popularModel.id!);
      return suggestions; // Devuelve la lista de sugerencias
    } catch (e) {
      // Maneja el error como prefieras
      print('Error cargando las sugerencias: $e');
      return []; // Devuelve una lista vacía en caso de error
    }
  }

  void _loadReviews() async {
    final popularModel =
        ModalRoute.of(context)!.settings.arguments as PopularModel;
    final reviewFetcher = MovieCastFetcher();

    try {
      reviews = await reviewFetcher.getReviews(popularModel.id!);
    } catch (e) {
      print('Error cargando las reseñas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final popularModel =
        ModalRoute.of(context)!.settings.arguments as PopularModel;
    //Se calcula la popularidad
    //asumiendo que 1000 es el valor máximo posible
    double popularityPercentage = (popularModel.voteAverage! / 10) * 100;
    int fullStars = (popularityPercentage / 20)
        .round(); // Dividimos por 20 porque 100% / 5 estrellas = 20% por estrella
    int halfStars = popularityPercentage % 20 >= 10
        ? 1
        : 0; // Verificamos si hay una estrella media
    //int emptyStars = 5 - fullStars - halfStars;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 7, 30),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            key: favoriteKey,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed:
                _toggleFavorite, // Llama al método para agregar o eliminar de favoritos
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: 'poster_${popularModel.id}',
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          'https://image.tmdb.org/t/p/w500/${popularModel.backdropPath}'),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            Positioned.fill(
              child:
                  //Efecto de Difuminacion
                  Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black.withOpacity(1),
                    ],
                  ),
                ),
              ),
            ),
            //Encabezado con imagen y titulo de la pelicula
            //Hero para enlazar la animacion
            //Titulo pelicula en idioma regional y original
            Positioned(
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    popularModel.title!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(1),
                      shadows: const [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    popularModel.originalTitle!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(1),
                      shadows: const [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(0, 0),
                        ),
                      ],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            //Seccion para la sinopsis, ranking y actores
            Positioned(
              // Ajusta la posición según sea necesario
                //color: const Color.fromARGB(255, 1, 7, 30),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Sinopsis',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(1),
                            shadows: const [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            popularModel.overview?.isNotEmpty ?? false
                                ? popularModel.overview!
                                : "Sinopsis no disponible",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(1),
                              shadows: const [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 15),
                        Text(
                          'Reparto',
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white.withOpacity(1),
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: cast.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(10),
                                  child: Text(
                                    cast[index],
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(1),
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: Colors.black,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }),
                        ),
                        const Divider(),
                        const SizedBox(height: 15),
                        Text(
                          'Ranking',
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white.withOpacity(1),
                              shadows: const [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black,
                                  offset: Offset(0, 0),
                                ),
                              ],
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            if (index < fullStars) {
                              return const Icon(Icons.star,
                                  color: Colors.yellow);
                            } else if (index < fullStars + halfStars) {
                              return const Icon(Icons.star_half,
                                  color: Colors.yellow);
                            } else {
                              return const Icon(Icons.star_border,
                                  color: Colors.grey);
                            }
                          }),
                        ),
                        const SizedBox(height: 5),
                        const Divider(),
                        const SizedBox(height: 30),
                        //Espaciado entre titulos
                        Text(
                          'Trailer',
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white.withOpacity(1),
                              shadows: const [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black,
                                  offset: Offset(0, 0),
                                ),
                              ],
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        isLoading
                            ? const CircularProgressIndicator()
                            // ignore: unnecessary_null_comparison
                            : _controller != null
                                ? YoutubePlayerBuilder(
                                    player: YoutubePlayer(
                                      controller: _controller,
                                      showVideoProgressIndicator: true,
                                    ),
                                    builder: (context, player) {
                                      return Column(
                                        children: [
                                          // some widgets
                                          player,
                                          //some other widgets
                                        ],
                                      );
                                    },
                                  )
                                : const Text('Sin trailer disponible.'),
                        const Divider(),
                        const SizedBox(height: 30),
                        const Text(
                          'Sugerencias',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          height: 590,
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: _loadSuggestions(),
                            builder: ((context, snapshot) {
                              if (snapshot.hasData) {
                                return PageView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: ((context, index) {
                                    return Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(10.0),
                                          child: Image.network(
                                            'https://image.tmdb.org/t/p/w500/${snapshot.data![index]['poster_path']}',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Text(
                                          snapshot.data![index]
                                              ['original_title'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              color:
                                                  Colors.white.withOpacity(1),
                                              shadows: const [
                                                Shadow(
                                                  blurRadius: 10.0,
                                                  color: Colors.black,
                                                  offset: Offset(0, 0),
                                                ),
                                              ],
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    );
                                  }),
                                );
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              }
                              return const CircularProgressIndicator();
                            }),
                          ),
                        ),
                        const Text(
                          'Reseñas',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              showReviews = !showReviews;
                            });
                          },
                          icon: const Icon(
                            Icons.remove_red_eye,
                            color: Color.fromARGB(255, 13, 50, 130),
                          ),
                          label: const Text(
                            'Visualizar',
                            style: TextStyle(
                              color: Color.fromARGB(255, 13, 50, 130),
                            ),
                          ),
                        ),
                        if (showReviews)
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: reviews.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: reviews.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          const Divider(),
                                          Text(
                                            reviews[index],
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(1),
                                              shadows: const [
                                                Shadow(
                                                  blurRadius: 10.0,
                                                  color: Colors.black,
                                                  offset: Offset(0, 0),
                                                ),
                                              ], // Color blanco para el texto de las reseñas
                                            ),
                                          ),
                                          const Divider(), // Agregar una línea después de cada reseña
                                          const SizedBox(
                                              height:
                                                  10), // Espacio de separación entre las reseñas
                                        ],
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Text(
                                      'Por el momento no hay reseñas de esta película',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 191, 191, 191),
                                      ),
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
              
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
