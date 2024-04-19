import 'HamburguesaNormalBuilder.dart';
import 'ObservadorPedido.dart';
import 'Subject.dart';
import 'Pedido.dart';
import 'HamburguesaBuilder.dart';

class Cocinero implements Subject {
  late HamburguesaBuilder _builder;
  String status = "Tomando pedido";
  List<ObservadorPedido> observers = [];
  Pedido pedidoActual = Pedido();

  Cocinero(){}

  Cocinero.Parametros(HamburguesaBuilder builder) {
    _builder = builder;
  }

  void buildHamburguesa() {
    status = "Cocinando";

    _builder.aniadePan();
    _builder.aniadeLechuga();
    _builder.aniadeTomate();
    if (_builder is HamburguesaNormalBuilder) {
      (_builder as HamburguesaNormalBuilder).aniadeQuesoCabra();
    }
    _builder.aniadeCebolla();
    _builder.aniadePepinillos();
    _builder.aniadeBacon();
    _builder.aniadeCarne();
    _builder.aniadePrecio();

    pedidoActual.aniadeHamburguesa(_builder.hamburguesa);
    status = "Tomando pedido";
  }

  void cambiaReceta(HamburguesaBuilder builder) {
    _builder = builder;
  }

  Pedido getPedido(){
    return this.pedidoActual;
  }

  @override
  void attach(ObservadorPedido observer) {
    observers.add(observer);
  }

  @override
  void detach(ObservadorPedido observer) {
    observers.remove(observer);
  }

  @override
  String notify() {
    String valor="";
    for (var notified in observers) {
       valor = notified.update(pedidoActual);
    }
    pedidoActual = Pedido();
    return valor;
  }
}