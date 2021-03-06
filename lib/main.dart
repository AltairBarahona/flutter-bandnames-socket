import 'package:band_names/pages/status.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart'; //1 propios de flutter
import 'package:band_names/pages/home.dart';
import 'package:provider/provider.dart'; //2 de terceros
//3 los nuestros

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SocketService()),
      ],
      child: MaterialApp(
        title: 'MaterialApp',
        initialRoute: "home",
        //los routes son un mapa
        routes: {
          /*es (_), ahí iría el build context pero no lo usaremos por eso queda así*/
          "home": (_) => HomePage(),
          "status": (_) => StatusPage(),
        },
      ),
    );
  }
}
/*Utilicé snippets con ctrl+shift+p ahí puedo definir "atajos para crear
código" */
