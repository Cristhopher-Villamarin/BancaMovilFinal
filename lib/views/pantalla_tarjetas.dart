import 'package:banca_movil_final/Model/UserI.dart';
import 'package:flutter/material.dart';
import 'package:banca_movil_final/Model/CardUser.dart'; // Importa el modelo Card
import 'package:banca_movil_final/Controller/CardController.dart'; // Importa el controller

class PantallaTarjetas extends StatefulWidget {
  final UserI userI;

  const PantallaTarjetas({required this.userI});

  @override
  _PantallaTarjetasState createState() => _PantallaTarjetasState();
}

class _PantallaTarjetasState extends State<PantallaTarjetas> {
  List<CardUser> tarjetas = []; // Lista para almacenar las tarjetas

  final TextEditingController _tarjetaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarTarjetas(); // Cargar las tarjetas al iniciar la pantalla
  }

  // Método para cargar las tarjetas desde la API
  void _cargarTarjetas() async {
    List<CardUser>? cards = await CardController.getCardsByUser(widget.userI.id); // Usar el ID del usuario correspondiente
    if (cards != null) {
      setState(() {
        tarjetas = cards;
      });
    }
  }

  // Método para mostrar un diálogo de confirmación antes de agregar la tarjeta
  void _mostrarDialogoAgregarTarjeta() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("¿Está seguro que desea pedir una tarjeta?"),
          content: Text("Al confirmar, su tarjeta será creada y generada automáticamente."),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text("Aceptar"),
              onPressed: () async {
                var newCard = await CardController.addCard(CardUser(
                  id: 0, // El id se generará automáticamente en el backend
                  user: UserI(id: widget.userI.id, email: "", name: "", numeroCuenta: "", saldo: 0), // Usar el ID del usuario correspondiente
                  cardNumber: "", // El número se genera automáticamente en el backend
                  frozen: false,
                ));
                if (newCard != null) {
                  setState(() {
                    tarjetas.add(newCard);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tarjeta agregada correctamente, se enviara su tarjeta en 2 días laborables')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al agregar la tarjeta')),
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Método para congelar o descongelar la tarjeta
  void _congelarTarjeta(int index) async {
    var card = tarjetas[index];
    var updatedCard;
    if (card.frozen) {
      updatedCard = await CardController.unfreezeCard(card.id);
    } else {
      updatedCard = await CardController.freezeCard(card.id);
    }

    if (updatedCard != null) {
      setState(() {
        tarjetas[index] = updatedCard;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar el estado de la tarjeta')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mis Tarjetas"), backgroundColor: Colors.lightBlueAccent),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: tarjetas.length,
          itemBuilder: (context, index) {
            return _buildTarjetaVisual(index);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarTarjeta,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTarjetaVisual(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: tarjetas[index].frozen ? Colors.grey[300] : Colors.black87,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    'assests/Mastercard-logo.png', // Ajusta la ruta del logo
                    height: 40,
                  ),
                ),
                Center(
                  child: Text(
                    "**** **** **** ${tarjetas[index].cardNumber.substring(15)}", // El número de la tarjeta se muestra aquí
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tarjetas[index].frozen ? "Tarjeta Congelada" : "Activa",
                      style: TextStyle(
                        fontSize: 16,
                        color: tarjetas[index].frozen ? Colors.red : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.ac_unit, color: Colors.white),
                          onPressed: () => _congelarTarjeta(index),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
