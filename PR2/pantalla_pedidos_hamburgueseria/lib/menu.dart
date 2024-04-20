import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pantalla_pedidos_hamburgueseria/model/Cocinero.dart';
import 'package:pantalla_pedidos_hamburgueseria/model/HamburguesaNormalBuilder.dart';
import 'package:pantalla_pedidos_hamburgueseria/model/HamburguesaSinGlutenBuilder.dart';
import 'package:pantalla_pedidos_hamburgueseria/model/HamburguesaVeganaBuilder.dart';
import 'package:pantalla_pedidos_hamburgueseria/model/ObservadorPedido.dart';
import 'model/Pedido.dart';
import 'model/Hamburguesa.dart';
import 'model/DisplayPedidos.dart';

class Menu extends StatefulWidget {
  // Necesitamos estado para actulizar el carrito
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  DisplayPedidos _display = DisplayPedidos();
  int _cantidad = 0;
  Cocinero _cocinero = Cocinero();
  List<String> _pedidoActual = [];

  @override
  void initState() {
    super.initState();
    _cocinero.attach(_display);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Bienvenido'),
            SizedBox(width: 8),
            IconButton(
              // Cambiamos el texto por un IconButton para el carrito
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                _mostrarPedido(context);
              },
            ),
            SizedBox(width: 8),
            Text('$_cantidad'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondo.jpg'), // Ruta de la imagen de fondo
            fit: BoxFit.cover, // Ajuste de la imagen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              _botonHamburguesa(
                  'assets/normal.jpg', "Hamburguesa normal", 5.00),
              SizedBox(height: 20),
              _botonHamburguesa(
                  "assets/vegana.jpg", "Hamburguesa vegana", 5.50),
              SizedBox(height: 20),
              _botonHamburguesa(
                  "assets/singluten.jpg", "Hamburguesa sin gluten", 6.00),
            ],
          ),
        ),
      ),
    );
  }

  // Crea widgets de los botones de las hamburguesas según los parámetros especificados
  Widget _botonHamburguesa(String hamburguesaImagePath, String nombre, double precio) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 32.0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(hamburguesaImagePath),
                fit: BoxFit.fitHeight,
              ),
            ),
            height: 150,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                _agregarAlCarrito(nombre);
              },
              child: Text(
                nombre,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Muestra la barra emergente con la información que se le pase como argumento
  void mostrarSnackBar(BuildContext context, String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 500), // Duración del snackbar
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Cada vez que se pulse un botón de la hamburguesa, añadimos la hamburguesa al pedido que se está realizando
  void _agregarAlCarrito(String hamburguesa) {
    setState(() {

      this._pedidoActual.add(hamburguesa);
      _cantidad++;
    });
    mostrarSnackBar(context, "Añadiendo al pedido una $hamburguesa ...");
  }

  // Abre una ventana emergente mostrando los datos del pedido actual. Contiene los botones de finalizar pedido y de resetear pedido)
  void _mostrarPedido(BuildContext context) {
    // Precio total del carrito
    // Fold itera sobre los elementos de una lista
    // totalAcumulado valor hasta el momento del pedido
    // Hambuguesa elemento actual de la lista
    double total = _calculaTotalPedido(_pedidoActual);
    showDialog(
      // Abre la ventana para mostrar las hamburguesas en el pedido
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hamburguesas en el carrito'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._pedidoActual.map((hamburguesa) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // Distribuye los elementos a lo largo del espacio disponible
                    children: [
                      Text("${hamburguesa}"),
                      Text("${_getPrecioHamburguesa(hamburguesa)}\€"),
                    ],
                  );
                }).toList(), // Precio total
                SizedBox(height: 20), // Margen
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Total:  '),
                    Text('${total.toStringAsFixed(2)}\€',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Center(
                  // Centrar Finalizar pedido
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Colors.redAccent), // Fondo rojo
                      foregroundColor: MaterialStateProperty.all(
                          Colors.black), // Texto negro
                    ),
                    child: Text('Finalizar Pedido'),
                    onPressed: () {
                      _finalizarPedido(context);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Cuando finalizamos el pedido, el cocinero empieza a cocinar. Reseteamos el carrito para poder empezar otro pedido mientras se va preparando el anterior.
  void _finalizarPedido(BuildContext context) {
    // Finalizar pedido, limpiar el carrito y contador
    setState(() {
      if (_pedidoActual.length > 0) {
        _cocinero.cocinaPedido(_pedidoActual, context);
        _pedidoActual.clear();
        _cantidad = 0;
      }
      else {
        mostrarSnackBar(context, "El pedido está vacío");
      }
    });
  }

  // Cuando pulsamos el botón de limpiar el carrito, para que reseteemos el pedido y podamos empezar desde 0
  void _clearPedido() {
    // Finalizar pedido, limpiar el carrito y contador
    setState(() {
      if (_pedidoActual.length > 0) {
        _pedidoActual.clear();
        _cantidad = 0;
      }
      else {
        mostrarSnackBar(context, "El pedido está vacío");
      }
    });
  }

  // Calculo del precio de un pedido entero
  double _calculaTotalPedido(List<String> pedido) {
    double total = 0;
    for (String hamburguesa in pedido) {
      total += _getPrecioHamburguesa(hamburguesa);
    }
    return total;
  }

  // Obtener el precio de cada hamburguesa según el nombre. Si no está en la carta el precio es de 0
  double _getPrecioHamburguesa(String hamburguesa) {
    switch (hamburguesa) {
      case "Hamburguesa normal":
        {
          return 5;
        }
      case "Hamburguesa vegana":
        {
          return 6;
        }
      case "Hamburguesa sin gluten":
        {
          return 5.5;
        }
      default:
        return 0;
    }
  }
}