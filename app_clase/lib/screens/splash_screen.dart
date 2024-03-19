import 'package:flutter/material.dart';
import 'package:app_clase/screens/login_screen.dart';
import 'package:splash_view/source/presentation/pages/pages.dart';
import 'package:splash_view/source/presentation/widgets/done.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashView(
      backgroundColor: Colors.black,
      //logo:Image.network('https://wallpapercave.com/wp/wp4667133.jpg',
        //        height: 250),
      loadingIndicator: Image.asset('images/loading.gif'),
      done: Done(const LoginScreen(),
      animationDuration: const Duration(milliseconds: 3000)
      ),
    );
  }
}