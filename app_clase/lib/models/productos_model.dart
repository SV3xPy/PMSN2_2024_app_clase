class ProductosModel {
  int? idProducto;
  String? nomProducto;
  int? canProducto;
  String? fechaCaducidad;
  //constructor simplificado verdad
  ProductosModel({
    this.idProducto, 
    this.nomProducto,
    this.canProducto, 
    this.fechaCaducidad});
  //No podemos sobreescribir constructores por eso usamos un nombradi
  factory ProductosModel.fromMap(Map<String,dynamic> producto){
    return ProductosModel(
      idProducto: producto['idProducto'],
      nomProducto: producto['nomProducto'],
      canProducto: producto['canProducto'],
      fechaCaducidad:producto['fechaCaducidad']
    );
  }
}
