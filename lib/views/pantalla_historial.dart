import 'package:banca_movil_final/Controller/TransactionController.dart';
import 'package:banca_movil_final/Model/Transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:banca_movil_final/Model/UserI.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Historial de Transacciones',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              ...transaccionesFiltradas.map((transaccion) {
                return pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 10),
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Monto: \$${transaccion.amount.toStringAsFixed(2)}"),
                      pw.Text("Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(transaccion.transactionDate)}"),
                      pw.Text(transaccion.type, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Historial de Transacciones"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'Descargar PDF',
            onPressed: _downloadPdf,
          )
        ],
      ),
      body: Column(
        children: [
          // Sección de filtros con diseño unificado
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _seleccionarFecha(context, true),
                          child: Text(fechaInicio == null
                              ? "Fecha inicio"
                              : DateFormat('dd/MM/yyyy').format(fechaInicio!)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _seleccionarFecha(context, false),
                          child: Text(fechaFin == null
                              ? "Fecha fin"
                              : DateFormat('dd/MM/yyyy').format(fechaFin!)),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
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
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Sección de listado de transacciones
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Icon(
                      transaccion.amount > 0
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: transaccion.amount > 0 ? Colors.green : Colors.red,
                    ),
                    title: Text("Monto: \$${transaccion.amount.toStringAsFixed(2)}"),
                    subtitle: Text("Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(transaccion.transactionDate)}"),
                    trailing: Text(transaccion.type,
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
