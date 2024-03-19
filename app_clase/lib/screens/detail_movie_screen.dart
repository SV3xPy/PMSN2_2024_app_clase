import 'package:app_clase/models/popular_movie.dart';
import 'package:flutter/material.dart';
import 'package:app_clase/network/api_trailer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailMovieScreen extends StatefulWidget {
  const DetailMovieScreen({Key? key}) : super(key: key);

  @override
  State<DetailMovieScreen> createState() => _DetailMovieScreenState();
}

class _DetailMovieScreenState extends State<DetailMovieScreen> {
  late YoutubePlayerController _controller;
  bool isLoading = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTrailer();
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

  @override
  Widget build(BuildContext context) {
    final popularModel =
        ModalRoute.of(context)!.settings.arguments as PopularModel;
    //Se calcula la popularidad
    //asumiendo que 1000 es el valor máximo posible
    double popularityPercentage = (popularModel.voteAverage! / 10) * 100;
    return Scaffold(
      body: Column(
        children: [
          //Encabezado con imagen y titulo de la pelicula
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          'https://image.tmdb.org/t/p/w500/${popularModel.backdropPath}'),
                    ),
                  ),
                ),
                //Efecto de Difuminacion
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.transparent,
                        Colors.white,
                      ],
                    ),
                  ),
                ),
                //Titulo pelicula en idioma regional y original
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        popularModel.title!,
                        style:
                            const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        popularModel.originalTitle!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
                color: Colors.black,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            popularModel.overview?.isNotEmpty ?? false
                                ? popularModel.overview!
                                : "Descripción no disponible",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Ranking',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CircularProgressIndicator(
                          //Se normaliza en un rango 0.0 - 1.0
                          value: popularityPercentage / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey[300]!,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 79, 88, 169)),
                        ),
                        const SizedBox(height: 30),
                        //Espaciado entre titulos
                        const Text(
                          'Trailer',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        isLoading
                            ? const CircularProgressIndicator()
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
                                : const Text('Sin trailer disponible :('),
                      ],
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
