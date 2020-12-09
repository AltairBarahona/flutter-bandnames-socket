import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';

/*era stateless pero lo cambiamos a stateful porque cuando lo conectemos con los
sockets ya no será necesario pero por el momento necesito que esté así para que
funciones de forma local hasta que lo conecte con el backend*/
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'banda1', votes: 5),
    Band(id: '2', name: 'banda2', votes: 2),
    Band(id: '3', name: 'banda3', votes: 4),
    Band(id: '4', name: 'banda4', votes: 5),
    Band(id: '5', name: 'banda5', votes: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BandNames",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 3,
      ),
      body: ListView.builder(
        /*Crear elementos de la lista bajo demanda */
        itemCount: bands.length,
        itemBuilder: (context, index) => _bandTile(bands[index]),
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
    return Dismissible(
      //key es un identificador único
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print("Direction: $direction");
        print("Is: ${band.id}");
        //todo: llamar el borrado en el server
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
          print(band.name);
        },
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          builder: (context) {
            return AlertDialog(
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
            );
          },
          context: context);
    }

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
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
          );
        },
      );
    }
  }

  void addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      //lo podemos agregar
      this.bands.add(Band(
            id: DateTime.now().toString(),
            name: name,
            votes: 0,
          ));

      setState(() {});
    }
    //cierro la ventana emergente
    Navigator.pop(context);
  }
}
