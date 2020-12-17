class Band {
  String id; //generado por el backend al crearlo
  String name; //nomre de la banda
  int votes; //número de votos
  /*El constructor tiene llaves para que podamos ponerles nombre
  a estas propiedades */
  Band({
    this.id,
    this.name,
    this.votes,
  });

  /*Al conectar la app con el backend, el backend responderá con un mapa, no con
  strings por los sockets.
  UItilizaremos un factory constructor que es un constructor que recibe cierto tipo
  de argumentos y regresa una nueva instancia de la clase

  .fromMap es el nombre de este factory constructor que recibe un mapa que tiene
  como llave Strings y el valor puede ser dynamic. Regresa una Band de la forma 
  corta porque solo es una línea en lugar de return Band();
  */

  factory Band.fromMap(Map<String, dynamic> obj) => Band(
        id: obj.containsKey('id') ? obj['id'] : 'no-id',
        name: obj.containsKey('name') ? obj['name'] : 'no-name',
        votes: obj.containsKey('votes') ? obj['votes'] : 'no-votes',
      );
}
