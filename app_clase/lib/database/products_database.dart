import 'dart:io';

import 'package:app_clase/models/productos_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProductsDatabase {
  // ignore: constant_identifier_names
  static const NAMEDB = 'DESPENSADB';
  // ignore: constant_identifier_names
  static const VERSIONDB = 1;

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    return _database = await _initDatabase();
  }

//Los parametros entre llaves se llaman nombrados, estos permiten especificar manualmente los
//parametros y no son posicionados es decir en base a la posicion
//El version: y demas son definiciones de parametros nombrados.
  Future<Database> _initDatabase() async {
    Directory folder = await getApplicationDocumentsDirectory();
    String pathDB = join(folder.path, NAMEDB);
    return openDatabase(
      pathDB,
      version: VERSIONDB,
      //onCreate es mejor cuando esta en desarrolo porque solo necesitamos crear todo
      //onUpgrade cambia las cosas cuando ya se esta en produccion
      onCreate: (db, version) {
        String query = '''CREATE TABLE tblProductos(
          idProducto INTEGER PRIMARY KEY,
          nomProducto VARCHAR(30),
          canProducto INTEGER,
          fechaCaducidad VARCHAR(10)
        )''';
        db.execute(query);
      },
    );
  }

  // ignore: non_constant_identifier_names
  Future<int> INSERTAR(Map<String, dynamic> data) async {
    var conexion = await database;
    return conexion.insert('tblProductos', data);
  }

  // ignore: non_constant_identifier_names
  Future<int> ACTUALIZAR(Map<String, dynamic> data) async {
    var conexion = await database;
    return conexion.update('tblProductos', data,
        where: 'idProducto = ?', whereArgs: [data['idProducto']]);
  }

  // ignore: non_constant_identifier_names
  Future<int> ELIMINAR(int idProducto) async {
    var conexion = await database;
    return conexion
        .delete('tblProductos', where: 'idProducto=?', whereArgs: [idProducto]);
  }

  // ignore: non_constant_identifier_names
  Future<List<ProductosModel>> CONSULTAR() async {
    var conexion = await database;
    var products = await conexion.query('tblProductos');
    return products.map((product) => ProductosModel.fromMap(product)).toList();
  }
}
