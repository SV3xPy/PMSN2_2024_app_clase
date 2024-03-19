import 'package:flutter/material.dart';
import 'package:app_clase/database/products_database.dart';
import 'package:app_clase/models/productos_model.dart';
import 'package:app_clase/screens/app_value_notifier.dart';
import 'package:intl/intl.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class DespensaScreen extends StatefulWidget {
  const DespensaScreen({super.key});

  @override
  State<DespensaScreen> createState() => _DespensaScreenState();
}

class _DespensaScreenState extends State<DespensaScreen> {
  ProductsDatabase? productsDB;
  @override
  void initState() {
    super.initState();
    productsDB = ProductsDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi depsensa :)'),
        actions: [
          IconButton(
            onPressed: () {
              showModal(context, null);
            },
            icon: const Icon(Icons.store_rounded),
          )
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: AppValueNotifier.banProducts,
          builder: (context, value, _) {
            return FutureBuilder(
              future: productsDB!.CONSULTAR(),
              builder: (context, AsyncSnapshot<List<ProductosModel>> snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something was wrong! :()'),
                  );
                } else {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return itemDespensa(snapshot.data![index]);
                        },
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
              },
            );
          }),
    );
  }

  Widget itemDespensa(ProductosModel producto) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      height: 100,
      child: Column(children: [
        Text(producto.nomProducto!),
        Text(producto.fechaCaducidad!),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                onPressed: () {
                  showModal(context, producto);
                },
                icon: const Icon(Icons.edit)),
            IconButton(
              onPressed: () async {
                ArtDialogResponse response = await ArtSweetAlert.show(
                    barrierDismissible: false,
                    context: context,
                    artDialogArgs: ArtDialogArgs(
                        denyButtonText: "Cancel",
                        title: "Are you sure?",
                        text: "You won't be able to revert this!",
                        confirmButtonText: "Yes, delete it",
                        type: ArtSweetAlertType.warning));

                if (response.isTapConfirmButton) {
                  productsDB!.ELIMINAR(producto.idProducto!).then((value) {
                    if (value > 0) {
                      ArtSweetAlert.show(
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                              type: ArtSweetAlertType.success,
                              title: "Deleted!"));
                      AppValueNotifier.banProducts.value =
                          !AppValueNotifier.banProducts.value;
                    }
                  });
                  return;
                }
              },
              icon: const Icon(Icons.delete),
            )
          ],
        )
      ]),
    );
  }

  showModal(context, ProductosModel? producto) {
    final conNombre = TextEditingController();
    final conCantidad = TextEditingController();
    final conFecha = TextEditingController();
    if (producto != null) {
      conNombre.text = producto.nomProducto!;
      conCantidad.text = producto.canProducto!.toString();
      conFecha.text = producto.fechaCaducidad!;
    }
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
          if (producto == null) {
            productsDB!.INSERTAR({
              "nomProducto": conNombre.text,
              "canProducto": int.parse(conCantidad.text),
              "fechaCaducidad": conFecha.text
            }).then((value) {
              Navigator.pop(context);
              String msg = "";
              if (value > 0) {
                AppValueNotifier.banProducts.value =
                    !AppValueNotifier.banProducts.value;
                msg = "Producto insertado";
                //var snackbar = SnackBar(content: Text(msg));
                //ScaffoldMessenger.of(context).showSnackBar(snackbar);
              } else {
                msg = "Ocurrio un error :()";
              }
              var snackbar = SnackBar(content: Text(msg));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            });
          } else {
            productsDB!.ACTUALIZAR({
              "idProducto": producto.idProducto,
              "nomProducto": conNombre.text,
              "canProducto": int.parse(conCantidad.text),
              "fechaCaducidad": conFecha.text
            }).then((value) {
              Navigator.pop(context);
              String msg = "";
              if (value > 0) {
                AppValueNotifier.banProducts.value =
                    !AppValueNotifier.banProducts.value;
                msg = "Producto actualizado";
                //var snackbar = SnackBar(content: Text(msg));
                //ScaffoldMessenger.of(context).showSnackBar(snackbar);
              } else {
                msg = "Ocurrio un error :()";
              }
              var snackbar = SnackBar(content: Text(msg));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            });
          }
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
