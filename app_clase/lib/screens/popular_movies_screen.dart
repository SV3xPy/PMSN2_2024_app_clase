import 'package:flutter/material.dart';
import 'package:app_clase/network/api_popular.dart';
import 'package:app_clase/models/popular_movie.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PopularMoviesScreen extends StatefulWidget {
  const PopularMoviesScreen({super.key});

  @override
  State<PopularMoviesScreen> createState() => _PopularMoviesScreenState();
}

class _PopularMoviesScreenState extends State<PopularMoviesScreen> {
  ApiPopular? apiPopular;

  @override
  void initState() {
    super.initState();
    apiPopular = ApiPopular();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 7, 30),
        title: const Text(
          'Películas Populares',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            icon: const Icon(Icons.favorite, color: Colors.red),
          )
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 1, 7, 30),
      body: FutureBuilder(
        future: apiPopular!.getPopularMovie(),
        builder: (context, AsyncSnapshot<List<PopularModel>?> snapshot) {
          if (snapshot.hasData) {
            return GridView.builder(
              itemCount: snapshot.data!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .7,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/detail",
                      arguments: snapshot.data![index]),
                  child: Hero(
                    tag: 'poster_${snapshot.data![index].id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FadeInImage(
                        placeholder: const AssetImage('images/load.gif'),
                        image: NetworkImage(
                            'https://image.tmdb.org/t/p/w500/${snapshot.data![index].posterPath}'),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            if (snapshot.hasError) {
                Fluttertoast.showToast(
                msg: "Ah ocurrido un error",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return const Center(
                child:  Text('Ah ocurrido un error'), 
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        },
      ),
    );
  }
}
