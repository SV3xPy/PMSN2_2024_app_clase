import 'dart:io';
import 'package:app_clase/services/email_auth_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'select_photo_options_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  File? _image;
  bool _passwordVisible = false;
  final authFirebase = EmailAuthFirebase();

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      setState(() {
        _image = img;
        Navigator.of(context).pop();
      });
    } on PlatformException catch (e) {
      print(e);
      Navigator.of(context).pop();
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickImage,
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final conNombre = TextEditingController();
    final txtNombre = TextFormField(
      keyboardType: TextInputType.text,
      controller: conNombre,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: const InputDecoration(
        labelText: 'Nombre Completo',
        border: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 1.0),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Por favor ingrese su nombre completo';
        }
        return null;
      },
    );
    final conContrasena = TextEditingController();
    final FocusNode passwordFocusNode = FocusNode();
    final txtContrasena = TextFormField(
      controller: conContrasena,
      focusNode: passwordFocusNode,
      obscureText: !_passwordVisible,
      keyboardType: TextInputType.visiblePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        suffixIcon: IconButton(
          icon:
              Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
            passwordFocusNode.requestFocus();
          },
        ),
        border: const OutlineInputBorder(),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 1.0),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Por favor ingrese su contraseña';
        }
        return null;
      },
    );
    final conEmail = TextEditingController();
    final txtEmail = TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: conEmail,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 1.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu email';
        }
        const pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
        final regex = RegExp(pattern);
        if (!regex.hasMatch(value)) {
          return 'Por favor ingresa un email válido';
        }
        return null;
      },
    );

    final btnSubmit = ElevatedButton.icon(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          Fluttertoast.showToast(
            msg: "Todo en orden",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          authFirebase.signUpUser(name: conNombre.text, password: conContrasena.text, email: conEmail.text).then((value){
              Fluttertoast.showToast(
            msg: "Usuario dado de alta con exito.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          });
        }
      },
      icon: const Icon(
        Icons.send,
        size: 24,
      ),
      label: const Text(
        'Submit',
        style: TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
    const space = SizedBox(
      height: 20,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              txtNombre,
              space,
              txtEmail,
              space,
              txtContrasena,
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Center(
                    child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _showSelectPhotoOptions(context);
                  },
                  child: Center(
                    child: Container(
                        height: 125.0,
                        width: 125.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: _image == null
                              ? const Text(
                                  'Sin imagen',
                                  style: TextStyle(fontSize: 15),
                                )
                              : CircleAvatar(
                                  backgroundImage: FileImage(_image!),
                                  radius: 65.0,
                                ),
                        )),
                  ),
                )),
              ),
              btnSubmit,
            ]),
          ),
        ),
      ),
    );
  }
}
