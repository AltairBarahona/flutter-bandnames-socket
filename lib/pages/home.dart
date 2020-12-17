import 'dart:io';

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

/*era stateless pero lo cambiamos a stateful porque cuando lo conectemos con los
sockets ya no será necesario pero por el momento necesito que esté así para que
funciones de forma local hasta que lo conecte con el backend*/
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    /*Band(id: '1', name: 'banda1', votes: 5),
    Band(id: '2', name: 'banda2', votes: 2),
    Band(id: '3', name: 'banda3', votes: 4),
    Band(id: '4', name: 'banda4', votes: 5),
    Band(id: '5', name: 'banda5', votes: 3),*/
  ];

  @override
  void initState() {
    // TODO: implement initState
    //listen false porque no necesito redibujar nada cuando socketService actualice
    //porque es cuando se inicializa
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  /*Optimización para manejar el evento 'active-bands' */
  _handleActiveBands(dynamic payload) {
    /*casteo a lista porque es un alista. en tiempo de ejecución de sabe
      pero al escribir el código no. así obtengo el .map que me sirve
      para transfornar cada valor interno en un listado.
      Ahora puedo usar el factory constructor, esto crea un iterable pero
      no es una lista, por eso lo paso a toList para que se haga una lista.
      */
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

//cuando se vaya a destruir el home
  /*@override
  void dispose() {
    // TODO: implement dispose
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands'); //dejo de escuchar

    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    //provider para gestionar estado del servidor
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BandNames",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 3,
        actions: <Widget>[
          //icono para ver si estoy conectado o no
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _showGraph(),
          /*Me da un error porque la columna no le dice
          al listview cuánto espacio tiene para
          renderizar, por eso lo envuelvo en un expanded*/
          Expanded(
            child: ListView.builder(
              /*Crear elementos de la lista bajo demanda */
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          addNewBand();
        },
        elevation: 3,
      ),
    );
  }

  Widget _bandTile(Band band) {
    //necesito que busque el SocketServices
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      //key es un identificador único
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) {
        print("Is: ${band.id}");
        //todo: llamar el borrado en el server
        /*Emitir: delete-band, con {'id':band.id} 
        En backend crear el procedimiento delete band*/
        //socketService.emit('delete-band', {"id": band.id});
        socketService.socket.emit('delete-band', {"id": band.id});
      },
      background: Container(
        padding: EdgeInsets.only(left: 15),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Delete band",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            band.name.substring(0, 2),
          ),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          socketService.socket.emit('vote-band', {'id': band.id});
          print(band.id);
        },
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("New Band name:"),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
                child: Text("add"),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text)),
          ],
        ),
      );
    }

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text("New Band name:"),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Add"),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Dismiss"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }
  }

  void addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      /*Debo mandar una comunicación al servidor de sockets */
      /*emitir algo con provider para emitir el evento de sockets 
      con el nombre add-band, con valor {name: name}.
      En el backend debo escuchar ese evento, recibir el payload
      que viene con el name.
      Debemos crear una nueva banda, añadirla al arreglo de bandas
      y notificar a los clientes conectados que se añadió una nueva banda
      */
      final socketService = Provider.of<SocketService>(context, listen: false);

      socketService.socket.emit('add-band', {'name': name});

      /*lo podemos agregar
      this.bands.add(Band(
            id: DateTime.now().toString(),
            name: name,
            votes: 0,
          ));

      setState(() {});*/
    }
    //cierro la ventana emergente
    Navigator.pop(context);
  }

  Widget _showGraph() {
    /*Utilizó el código mostrado en el paquete */
    Map<String, double> dataMap = new Map();
    //dataMap.putItAbsent('Flutter', ()=>5);

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue,
      Colors.black54,
      Colors.pinkAccent,
      Colors.red,
      Colors.amber,
      Colors.lime
    ];

    /*PieChart necesita un tamaño porque
    está flexible gracias a la columna */
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 70,
        chartRadius: (MediaQuery.of(context).size.width / 3.2) * 1.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 20,
        //centerText: "HYBRID",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
        ),
      ),
    );

    /*Map<String, double> dataMap = {
      "Flutter": 10,
      "React": 3,
      "Xamarin": 2,
      "Ionic": 2,
      
    };*/
  }
}
