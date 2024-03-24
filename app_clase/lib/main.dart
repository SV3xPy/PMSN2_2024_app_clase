import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app_clase/screens/app_value_notifier.dart';
import 'package:app_clase/screens/dashboard_screen.dart';
import 'package:app_clase/screens/despensa_screen.dart';
import 'package:app_clase/screens/detail_movie_screen.dart';
import 'package:app_clase/screens/popular_movies_screen.dart';
import 'package:app_clase/screens/products_firebase_screen.dart';
import 'package:app_clase/screens/register_screen.dart';
import 'package:app_clase/screens/splash_screen.dart';
import 'package:app_clase/screens/favorite_movie_screen.dart';
//import 'package:app_clase/services/products_firebase.dart';
import 'package:app_clase/settings/theme.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAfhzs8C-NkIxQtLRj3BrTaNJ1ahrbJ6zs", // paste your api key here
      appId: "com.example.app_clase", //paste your app id here
      messagingSenderId: "458162643934", //paste your messagingSenderId here
      projectId: "pm2024-e444d", //paste your project id here
    ),
  );
  await Hive.initFlutter();
  await Hive.openBox('favorites');
  runApp(const MyApp());
}

//Para cambiarlo a stateful es control punto sobre el stateless
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: AppValueNotifier.banTheme,
        builder: (context, value, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: value
                ? ThemeApp.darkTheme(context)
                : ThemeApp().lightTheme(context),
            home: const SplashScreen(),
            routes: {
              "/dash": (BuildContext context) => const DashboardScreen(),
              "/despensa": (BuildContext context) => const DespensaScreen(),
              "/register": (BuildContext context) => const RegisterScreen(),
              "/movies": (BuildContext context) => const PopularMoviesScreen(),
              "/detail": (BuildContext context) => const DetailMovieScreen(),
              "/favorites":(BuildContext context) => const FavoriteMoviesScreen(),
              "/productsFirebase":(BuildContext context) => const ProductsFirebaseScreen(),
            },
          );
        });
  }
}
/*class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int contador = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Algo de inicio',
          style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
        ),
        drawer: Drawer(),
        floatingActionButton: FloatingActionButton(
          backgroundColor : Colors.red,
          onPressed: (){
            contador++;
            print(contador);
            setState(() {
              
            });
          },
          child: Icon(Icons.ads_click),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.network('https://wallpapercave.com/wp/wp4667133.jpg',
                height: 250),
              ),
            Text('Valor del contador $contador')],
          )
      ),
    );
  }
}*/