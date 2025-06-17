import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarProductoDialog extends StatefulWidget {
  final Map<String, dynamic> producto;
  final VoidCallback onActualizado;

  const EditarProductoDialog({
    super.key,
    required this.producto,
    required this.onActualizado,
  });

  @override
  State<EditarProductoDialog> createState() => _EditarProductoDialogState();
}

class _EditarProductoDialogState extends State<EditarProductoDialog> {
  final _tituloController = TextEditingController();
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _familiaController = TextEditingController();
  final _categoriaController = TextEditingController();

  Uint8List? _nuevaImagenBytes;
  String? _nombreNuevaImagen;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _tituloController.text = p['titulo'] ?? '';
    _precioController.text = (p['precio'] ?? '').toString();
    _descripcionController.text = p['descripcion'] ?? '';
    _familiaController.text = p['familia'] ?? '';
    _categoriaController.text = p['categoria'] ?? '';
  }

  Future<void> _seleccionarNuevaImagen() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _nuevaImagenBytes = result.files.single.bytes;
        _nombreNuevaImagen = result.files.single.name;
      });
    }
  }

  Future<void> _guardarCambios() async {
    final id = widget.producto['id'];
    final nuevoTitulo = _tituloController.text.trim();
    final nuevoPrecio = int.tryParse(_precioController.text.replaceAll('.', ''));
    final nuevaDesc = _descripcionController.text.trim();
    final nuevaFamilia = _familiaController.text.trim();
    final nuevaCategoria = _categoriaController.text.trim();
    String imagenUrl = widget.producto['imagen_url'];

    if (nuevoTitulo.isEmpty || nuevoPrecio == null || nuevaCategoria.isEmpty || nuevaFamilia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Faltan campos obligatorios'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_nuevaImagenBytes != null) {
      final path = 'producto_editado_${DateTime.now().millisecondsSinceEpoch}_$_nombreNuevaImagen';
      final storage = Supabase.instance.client.storage.from('juli3d');
      await storage.uploadBinary(path, _nuevaImagenBytes!, fileOptions: const FileOptions(upsert: true));
      imagenUrl = storage.getPublicUrl(path);
    }

    await Supabase.instance.client.from('juli3d').update({
      'titulo': nuevoTitulo,
      'precio': nuevoPrecio,
      'descripcion': nuevaDesc,
      'familia': nuevaFamilia,
      'categoria': nuevaCategoria,
      'imagen_url': imagenUrl,
    }).eq('id', id);

    if (mounted) {
      Navigator.pop(context);
      widget.onActualizado();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Producto actualizado correctamente'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 29, 36, 39),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _familiaController,
                decoration: const InputDecoration(labelText: 'Familia'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoría'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _seleccionarNuevaImagen,
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text('Cambiar imagen', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: color.primary),
              ),
              const SizedBox(height: 12),
              if (_nuevaImagenBytes != null)
                Image.memory(_nuevaImagenBytes!, height: 100)
              else
                Image.network(widget.producto['imagen_url'], height: 100, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardarCambios,
                child: const Text('Guardar cambios'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _familiaController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }
}
