import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Listascreen extends StatefulWidget {
  const Listascreen({super.key});

  @override
  State<Listascreen> createState() => _ListascreenState();
}

class _ListascreenState extends State<Listascreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("listas");
  List<Map<String, dynamic>> _listas = [];

  @override
  void initState() {
    super.initState();
    _cargarListas();
  }

  void _cargarListas() {
    _database.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _listas = data.entries.map((e) {
            return {
              "id": e.key,
              ...Map<String, dynamic>.from(e.value),
            };
          }).toList();
        });
      } else {
        setState(() {
          _listas = [];
        });
      }
    });
  }

  void _eliminarLista(String id) {
    _database.child(id).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista eliminada con éxito')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $error')),
      );
    });
  }

  void _mostrarModal(BuildContext context, Map<String, dynamic> lista) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController tituloController =
            TextEditingController(text: lista["titulo"]);
        final TextEditingController descripcionController =
            TextEditingController(text: lista["descripcion"]);
        final TextEditingController precioController =
            TextEditingController(text: lista["precio"].toString());

        return AlertDialog(
          title: Text('Editar Lista: ${lista["titulo"]}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: precioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedTitulo = tituloController.text.trim();
                final updatedDescripcion = descripcionController.text.trim();
                final updatedPrecio = double.tryParse(precioController.text.trim()) ?? 0.0;

                _database.child(lista["id"]).update({
                  "titulo": updatedTitulo,
                  "descripcion": updatedDescripcion,
                  "precio": updatedPrecio,
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lista actualizada con éxito')),
                  );
                  Navigator.pop(context);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar: $error')),
                  );
                });
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas'),
      ),
      body: _listas.isEmpty
          ? const Center(child: Text('No hay listas disponibles'))
          : ListView.builder(
              itemCount: _listas.length,
              itemBuilder: (context, index) {
                final lista = _listas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(lista["titulo"] ?? ""),
                    subtitle: Text('Precio: \$${lista["precio"] ?? 0.0}'),
                    onTap: () => _mostrarModal(context, lista),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarLista(lista["id"]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
