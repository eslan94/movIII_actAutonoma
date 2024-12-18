import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  runApp(const MaterialApp(
    home: Recomendacionesscreen(),
  ));
}

class Recomendacionesscreen extends StatefulWidget {
  const Recomendacionesscreen({super.key});

  @override
  State<Recomendacionesscreen> createState() => _RecomendacionesscreenState();
}

class _RecomendacionesscreenState extends State<Recomendacionesscreen> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref("listas");

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  void _guardarLista() {
    final id = _idController.text.trim();
    final titulo = _tituloController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final precio = _precioController.text.trim();

    if (id.isNotEmpty && titulo.isNotEmpty && descripcion.isNotEmpty && precio.isNotEmpty) {
      _database.child(id).set({
        "titulo": titulo,
        "descripcion": descripcion,
        "precio": double.tryParse(precio) ?? 0.0, // Convertimos el precio a double
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lista guardada con éxito')),
        );
        _idController.clear();
        _tituloController.clear();
        _descripcionController.clear();
        _precioController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Listas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarLista,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
