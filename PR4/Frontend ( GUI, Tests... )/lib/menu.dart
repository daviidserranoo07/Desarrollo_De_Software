import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pantalla_pedidos_hamburgueseria/model/Cocinero.dart';
import 'package:pantalla_pedidos_hamburgueseria/model/Hamburguesa.dart';
import 'model/Pedido.dart';
import 'model/DisplayPedidos.dart';

class Menu extends StatefulWidget {
  // Necesitamos estado para actulizar el carrito
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {

  //Tema API Rest
  final TextEditingController _controller = TextEditingController();

  List<Pedido> _historialPedidos = []; // Creamos una lista para el historial de pedidos
  late DisplayPedidos _display = DisplayPedidos();
  int _cantidad = 0;
  Cocinero _cocinero = Cocinero();
  List<String> _pedidoActual = [];
  late final List<String> users= ['juanmi', 'david', 'jesus', 'raul'];
  late String currentUser = users.first;
  late String dropdownValue = currentUser;


  @override
  void initState() {
    super.initState();
    _display = DisplayPedidos.Parametros(_historialPedidos, _actualizarHistorial); // Inicializar _display en initState
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _display.init(context); // Inicializa DisplayPedidos con el BuildContext válido
      _cocinero.attach(_display);
      _cargarPedidosIniciales();
    });
  }

  void _cargarPedidosIniciales() async {
    try{
      await _display.cargarPedidos(currentUser);
      setState(() {

      });
    }catch (e){
      print("Error cargando los pedidos: $e");
    }
  }

  void _aniadirPedido(Pedido pedido) async {
    if (pedido != null) {
      try {
        await _display.agregar(pedido);
      } catch (e) {
        print("Error aniadiendo pedido: $e");
      }
      setState(() {});
    }
  }

  void _marcarFinalizado(Pedido pedido) async {
    try {
      await _display.marcarFinalizado(pedido);
    } catch (e) {
      print("Error marcar pedido como finalizado: $e");
    }
    setState(() {});
  }

  void _borrarPedido(Pedido pedido) async {
    try {
      await _display.eliminar(pedido);
    } catch (e) {
      print("Error borrando pedido: $e");
    }
    setState(() {});
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
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                _mostrarPedido(context);
              },
            ),
            SizedBox(width: 8),
            Text('$_cantidad'),
            SizedBox(width: 75),
            DropdownButton<String>(
              value: currentUser,
              icon: Icon(Icons.arrow_downward),
              onChanged: (String? newValue) {
                if (newValue != null && newValue != currentUser) {
                  setState(() {
                    currentUser = newValue;
                    _pedidoActual.clear();
                    _cantidad = 0;
                    _cargarPedidosIniciales();
                  });
                }
              },
              items: users.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 60,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Historial de Pedidos'),
                    IconButton(
                      icon: Icon(Icons.close_sharp),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_display.historial.isEmpty)
              ListTile(
                title: Text('No hay pedidos en el historial'),
              )
            else
              ..._display.historial.map((pedido) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pedido: ${pedido.idPedido} listo',
                        style: TextStyle(color: Colors.green),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            print(pedido.id);
                            _borrarPedido(pedido);
                            _display.historial.remove(pedido);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Expanded(
                child: _botonHamburguesa(
                    'assets/normal.jpg', "Hamburguesa normal", 5.00),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _botonHamburguesa(
                    "assets/vegana.jpg", "Hamburguesa vegana", 5.50),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _botonHamburguesa(
                    "assets/singluten.jpg", "Hamburguesa sin gluten", 6.00),
              ),
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
    //mostrarSnackBar(context, "Añadiendo al pedido una $hamburguesa ...");
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
                    TextButton(
                      onPressed: () {
                        _clearPedido();
                        Navigator.of(context).pop(); // Opcional: cerrar el diálogo después de limpiar el pedido
                      },
                      child: Icon(Icons.delete), // Icono de basura
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.redAccent), // Fondo rojo
                        foregroundColor:
                        MaterialStateProperty.all(Colors.black), // Texto negro
                      ),
                      child: Text('Finalizar Pedido'),
                      onPressed: () {
                        _finalizarPedido(context);
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(width: 20),
                    Text('Total:  '),
                    Text('${total.toStringAsFixed(2)}\€',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Cuando finalizamos el pedido, el cocinero empieza a cocinar. Reseteamos el carrito para poder empezar otro pedido mientras se va preparando el anterior.
  void _finalizarPedido(BuildContext context) async {
    // Finalizar pedido, limpiar el carrito y contador
    if (_pedidoActual.isNotEmpty) {
      setState(() {
        mostrarSnackBar(context, "Cocinando pedido...");
        _actualizarHistorial();
      });

      List<String> listAux = List<String>.from(_pedidoActual);
      List<Hamburguesa> listaHAux = construyeListaHAux(listAux);
      double precio = _calculaTotalPedido(_pedidoActual);

      try {
        // Esperar 5 segundos antes de comenzar
        await Future.delayed(Duration(seconds: 4));

        setState(() {
          _cocinero.setPrecioPedido(precio);
          _cocinero.cocinaPedido(listAux, context);
          _cocinero.pedidoActual.usuario = currentUser;
          // Guardar en base de datos y asegurarse que se complete antes de continuar
          //_cocinero.pedidoActual.hamburguesas = listaHAux; //Asegurarnos que se manda bien la lista de hamburguesas (asincronia)
          print(_cocinero.pedidoActual);
          _aniadirPedido(_cocinero.pedidoActual);
          _cocinero.borrarPedidoActual();
        });

        // Esperar 7 segundos adicionales antes de marcar como finalizado
        await Future.delayed(Duration(seconds: 7));

        // Marcar el pedido como finalizado
        print(_cocinero.pedidoActual.id);
        _marcarFinalizado(_display.historial.last);

        setState(() {
          _pedidoActual.clear();
          _cantidad = 0;
        });
      } catch (e) {
        mostrarSnackBar(context, "Error procesando el pedido: $e");
        print('Error procesando el pedido: $e');
      }
    } else {
      mostrarSnackBar(context, "El pedido está vacío");
    }
  }

  // Cuando pulsamos el botón de limpiar el carrito, para que reseteemos el pedido y podamos empezar desde 0
  void _clearPedido() {
    // Finalizar pedido, limpiar el carrito y contador
    setState(() {
      if (_pedidoActual.length > 0) {
        _pedidoActual.clear();
        _cantidad = 0;
        mostrarSnackBar(context, "Limpiando pedido...");
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

  void _actualizarHistorial() {
    setState(() {}); // Forzar la actualización del estado para reflejar los cambios en el historial de pedidos en el Drawer
  }

  List<Hamburguesa> construyeListaHAux(List<String> listAux) { //metodo para hacer pruebas
    List<Hamburguesa> hamburguesas = [];

    for (String hamburguesaStr in listAux) {
      switch (hamburguesaStr) {
        case "Hamburguesa normal":
          hamburguesas.add(Hamburguesa(
            nombre: "Hamburguesa normal",
            pan: "Pan normal",
            lechuga: "Lechuga fresca",
            tomate: "Tomate pera",
            quesoCabra: "Queso de cabra recién cortado",
            cebolla: "Cebolla llorosa",
            pepinillos: "Pepinillos",
            bacon: "Bacon grasiento",
            carne: "Carne Wagyu",
            precio: 5.0,
          ));
          break;

        case "Hamburguesa vegana":
          hamburguesas.add(Hamburguesa(
            nombre: "Hamburguesa vegana",
            pan: "Pan normal",
            lechuga: "Lechuga fresca",
            tomate: "Tomate pera",
            quesoCabra: null,
            cebolla: "Cebolla llorosa",
            pepinillos: "Pepinillos",
            bacon: "Bacon Vegano reseco",
            carne: "Carne Vegana de dudosa procedencia",
            precio: 5.5,
          ));
          break;

        case "Hamburguesa sin gluten":
          hamburguesas.add(Hamburguesa(
            nombre: "Hamburguesa sin gluten",
            pan: "Pan sin gluten",
            lechuga: "Lechuga fresca",
            tomate: "Tomate pera",
            quesoCabra: null,
            cebolla: "Cebolla llorosa",
            pepinillos: "Pepinillos",
            bacon: "Bacon sin gluten",
            carne: "Carne de origen dudoso",
            precio: 6.0,
          ));
          break;

      // Agrega más casos según sea necesario para otros tipos de hamburguesas

        default:
          throw Exception("Tipo de hamburguesa no válido: $hamburguesaStr");
      }
    }

    return hamburguesas;
  }

}