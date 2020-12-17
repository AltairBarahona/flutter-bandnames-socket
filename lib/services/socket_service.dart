//todo esto es un servicio

import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
//importo como me indica socket_io_client

/*Hacemos un mixin con ChangeNotifier ya que este me ayudará a decirle a
provider cuando tiene que refrescar la interfaz de usuario o algún widget
cuando sucede un cambio que me interesa */

//enumeración para manejar los estados del server

enum ServerStatus {
  Online,
  Offline,
  Connecting,
}

class SocketService with ChangeNotifier {
  /*Ccontrolando acceso. Por defecto en conecting la primera vez que intento
  hacer la conexión voy a intentar hacer la conexión y aún no sé si está 
  online u offline pero si sé que estoy intentando conectarme*/
  ServerStatus _serverStatus = ServerStatus.Connecting;
  //quiero controlar cómo se va a exponer
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;
  SocketService() {
    //no quiero cargar mucho el constructor con información, por eso el _initConfig
    this._initConfig();
  }

  void _initConfig() {
    // Dart client
    _socket = IO.io('http://192.168.100.4:3000', {
      //propiedad para comunicarnos mediante websockets (lo configuramos en el backend)
      'transports': ['websocket'],
      //propiedad para conectarnos automáticamente o en determinados momentos
      'autoConnect': true,
    });
    this._socket.onConnect((_) {
      //print('connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

//Payload o el call back es de tipo dinámico y no se aconseja poner un tipado
//porque podríamos enviar cualquier tipo de iformación al emitir y por eso se
//queda como dinámico
    socket.on('nuevo-mensaje', (payload) {
      print('nuevo-mensaje:');
      print('nombre:' + payload['nombre']);
      print('mensaje: ' + payload['mensaje']);
      //debemos manejar esta excepción
      //Como es un mapa, todos los mapas tienen la propiedad .containsKey
      //para preguntar si viene el mensaje 2, y si existe lo muestro, caso contrario
      //muestro no hay
      //print('mensaje: ' + payload['mensaje2']);
      print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay');
    });
  }
}
