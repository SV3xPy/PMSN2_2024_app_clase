import 'package:flutter/material.dart';
import 'package:app_clase/services/products_firebase.dart';
import 'package:intl/intl.dart';

class ProductsFirebaseScreen extends StatefulWidget {
  const ProductsFirebaseScreen({super.key});

  @override
  State<ProductsFirebaseScreen> createState() => _ProductsFirebaseScreenState();
}

class _ProductsFirebaseScreenState extends State<ProductsFirebaseScreen> {
  final productsFirebase = ProductsFirebase();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.store),
        onPressed: () => showModal(context),
      ),
      appBar: AppBar(
        title: const Text('Hola'),
      ),
      body: StreamBuilder(
        stream: productsFirebase.consultar(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return Image.network(snapshot.data!.docs[index].get('imagen'));
              },
            );
          } else {
            if (snapshot.hasError) {
              return const Text('Error');
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }
        },
      ),
    );
  }

  showModal(context) {
    final conNombre = TextEditingController();
    final conCantidad = TextEditingController();
    final conFecha = TextEditingController();
    final txtNombre = TextFormField(
      keyboardType: TextInputType.text,
      controller: conNombre,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );

    final txtCantidad = TextFormField(
      keyboardType: TextInputType.number,
      controller: conCantidad,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
    const space = SizedBox(
      height: 10,
    );
    final txtFecha = TextFormField(
      controller: conFecha,
      keyboardType: TextInputType.none,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101));
        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          setState(() {
            conFecha.text =
                formattedDate; //set foratted date to TextField value.
          });
        }
      },
    );
    final btnAgregar = ElevatedButton.icon(
        onPressed: () {
          productsFirebase.insertar({
            'canProducto': conCantidad.text,
            'fechaCaducidad': conFecha.text,
            'imagen':
                'https://cdn2.telediario.mx/uploads/media/2023/05/11/recomendable-meter-sopas-microondas-envase.jpg',
            'nomProducto': conNombre.text,
          });
        },
        icon: const Icon(Icons.save),
        label: const Text('Guardar'));

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              txtNombre,
              space,
              txtCantidad,
              space,
              txtFecha,
              space,
              btnAgregar,
            ],
          );
        });
  }
}
