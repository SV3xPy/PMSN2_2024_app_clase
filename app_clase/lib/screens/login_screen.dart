import 'package:app_clase/services/email_auth_firebase.dart';
import 'package:app_clase/services/google_auth_firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_clase/screens/dashboard_screen.dart';
import 'package:app_clase/screens/register_screen.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _nameState();
}

// ignore: camel_case_types
class _nameState extends State<LoginScreen> {
  //bool isLoading = false;
  final authFirebase = EmailAuthFirebase();
  final authGoogle = GoogleAuthFirebase();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /*final txtUser = TextFormField(
    keyboardType: TextInputType.emailAddress,
    decoration: const InputDecoration(border: OutlineInputBorder()),
  );
  final pwdUser = TextFormField(
    keyboardType: TextInputType.text,
    obscureText: true,
    decoration: const InputDecoration(border: OutlineInputBorder()),
  );*/
  @override
  Widget build(BuildContext context) {
    final txtUser = TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
    bool isLoading = false;
    final pwdUser = TextFormField(
      controller: _passwordController,
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Map'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top,
      width: double.infinity,
      decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage('images/fondo.jpg'))),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 470,
            child: Opacity(
              opacity: .65,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                height: 165,
                width: MediaQuery.of(context).size.width * .9,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    txtUser,
                    const SizedBox(
                      height: 10,
                    ),
                    pwdUser
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 450,
            height: 180, // Altura deseada
            child: Image.asset(
              "images/logo_text.png",
              fit: BoxFit.fitWidth, // Ajusta la imagen al ancho del contenedor
            ),
          ),
          Positioned(
              bottom: 40,
              child: SizedBox(
                height: 190,
                width: MediaQuery.of(context).size.width -
                    MediaQuery.of(context).padding.top,
                child: ListView(shrinkWrap: true, children: [
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        isLoading = !isLoading;
                      });
                      Future.delayed(const Duration(milliseconds: 5000), () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ));
                      });
                    },
                    label: const Text(
                      "Registrarse con Email",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 45, 186, 239), // Color de fondo del botón
                      fixedSize: const Size(210, 45), // Tamaño del botón
                    ),
                  ),
                  SignInButton(Buttons.Email, onPressed: () {
                    setState(() {
                      isLoading = !isLoading;
                    });
                    //16-3-24
                    //Se incluye el login de Firebase
                    authFirebase
                        .signInUser(
                            email: _emailController.text,
                            password: _passwordController.text)
                        .then((value) {
                      if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuario NO VALIDADO.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, "/dash");
                      }
                    }).catchError((error) {
                      if (error is FirebaseAuthException) {
                        print('Error de autenticación: ${error.code}');
                        print(error.message);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.message ?? 'Error desconocido'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        // Manejar otros tipos de errores
                        print('Error desconocido: $error');
                      }
                    });
                  }),
                  SignInButton(Buttons.Google, onPressed: () {
                    setState(() {
                      isLoading = !isLoading;
                    });
                    authGoogle.signUpUser()
                        .then((value) {
                      if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuario NO VALIDADO.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, "/dash");
                      }
                    }).catchError((error) {
                      if (error is FirebaseAuthException) {
                        print('Error de autenticación: ${error.code}');
                        print(error.message);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.message ?? 'Error desconocido'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        // Manejar otros tipos de errores
                        print('Error desconocido: $error');
                      }
                    });
                  }),
                  SignInButton(Buttons.Facebook, onPressed: () {
                    setState(() {
                      isLoading = !isLoading;
                    });
                    Future.delayed(const Duration(milliseconds: 5000), () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ));
                    });
                  }),
                  SignInButton(Buttons.GitHub, onPressed: () {
                    setState(() {
                      isLoading = !isLoading;
                    });
                    Future.delayed(const Duration(milliseconds: 5000), () {
                      /*Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => new DashboardScreen(),
                          ))*/
                      Navigator.pushNamed(context, "/dash").then((value) {
                        setState(() {
                          isLoading != isLoading;
                        });
                      });
                    });
                  }),
                ]),
              )),
          isLoading
              ? const Positioned(
                  top: 260,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ))
              : Container()
        ],
      ),
    ));
  }
}
