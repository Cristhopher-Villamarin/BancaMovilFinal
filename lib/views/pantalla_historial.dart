import 'package:banca_movil_final/Controller/TransactionController.dart';
import 'package:banca_movil_final/Model/Transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:banca_movil_final/Model/UserI.dart';

class PantallaHistorial extends StatefulWidget {
  final UserI userI;
  const PantallaHistorial({required this.userI});

  @override
  _PantallaHistorialState createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  List<Transaction> transacciones = [];
  List<Transaction> transaccionesFiltradas = [];
  String? tipoSeleccionado;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  int limiteSeleccionado = 10;
  List<String> tiposDisponibles = [];

  @override
  void initState() {
    super.initState();
    _cargarTransacciones();
  }

  Future<void> _cargarTransacciones() async {
    try {
      List<Transaction> data = await TransactionController.getTransactionsByAccount(widget.userI.numeroCuenta ?? "");
      if (data.isNotEmpty) {
        setState(() {
          transacciones = data;
          tiposDisponibles = data.map((e) => e.type).toSet().toList();
          _filtrarTransacciones();
        });
      } else {
        throw Exception("No se encontraron transacciones");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _filtrarTransacciones() {
    setState(() {
      transaccionesFiltradas = transacciones.where((transaccion) {
        DateTime fecha = transaccion.transactionDate;
        bool cumpleFecha = true;
        if (fechaInicio != null && fechaFin != null) {
          cumpleFecha = fecha.isAfter(fechaInicio!.subtract(Duration(days: 1))) &&
              fecha.isBefore(fechaFin!.add(Duration(days: 1)));
        }
        bool cumpleTipo = tipoSeleccionado == null || transaccion.type == tipoSeleccionado;
        return cumpleFecha && cumpleTipo;
      }).take(limiteSeleccionado).toList();
    });
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fechaSeleccionada != null) {
      setState(() {
        if (esInicio) {
          fechaInicio = fechaSeleccionada;
        } else {
          fechaFin = fechaSeleccionada;
        }
        _filtrarTransacciones();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Historial de Transacciones"), backgroundColor: Colors.lightBlueAccent),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _seleccionarFecha(context, true),
                      child: Text(fechaInicio == null ? "Fecha inicio" : DateFormat('dd/MM/yyyy').format(fechaInicio!)),
                    ),
                    ElevatedButton(
                      onPressed: () => _seleccionarFecha(context, false),
                      child: Text(fechaFin == null ? "Fecha fin" : DateFormat('dd/MM/yyyy').format(fechaFin!)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      hint: Text("Seleccionar tipo"),
                      value: tipoSeleccionado,
                      onChanged: (String? newValue) {
                        setState(() {
                          tipoSeleccionado = newValue;
                          _filtrarTransacciones();
                        });
                      },
                      items: tiposDisponibles.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                    ),
                    DropdownButton<int>(
                      value: limiteSeleccionado,
                      onChanged: (int? newValue) {
                        setState(() {
                          limiteSeleccionado = newValue ?? 10;
                          _filtrarTransacciones();
                        });
                      },
                      items: [5, 10, 20, 50].map((int limite) {
                        return DropdownMenuItem<int>(
                          value: limite,
                          child: Text("Mostrar $limite"),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: transaccionesFiltradas.isEmpty
                ? Center(child: Text("No hay transacciones disponibles"))
                : ListView.builder(
              itemCount: transaccionesFiltradas.length,
              itemBuilder: (context, index) {
                var transaccion = transaccionesFiltradas[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(
                      transaccion.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                      color: transaccion.amount > 0 ? Colors.green : Colors.red,
                    ),
                    title: Text("Monto: \$${transaccion.amount.toStringAsFixed(2)}"),
                    subtitle: Text("Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(transaccion.transactionDate)}"),
                    trailing: Text(transaccion.type, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
