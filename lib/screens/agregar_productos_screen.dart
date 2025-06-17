import 'dart:typed_data';
import 'package:catalogo3d/widgets/animated_button.dart';
import 'package:catalogo3d/widgets/appbar.dart';
import 'package:catalogo3d/widgets/catalogo_header.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _tituloController = TextEditingController();
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _familiaController = TextEditingController();

  Uint8List? _imagenBytes;
  String? _nombreImagen;
  bool _subiendo = false;

  Future<void> _seleccionarArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imagenBytes = result.files.single.bytes!;
        _nombreImagen = result.files.single.name;
      });
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ $mensaje'), backgroundColor: Colors.red[800]),
    );
  }

  Future<void> _guardarProducto() async {
    // Validación de campos
    if (_tituloController.text.trim().isEmpty) {
      _mostrarError('Falta el título del producto');
      return;
    }

    if (_precioController.text.trim().isEmpty) {
      _mostrarError('Falta el precio del producto');
      return;
    }

    final parsedPrecio = int.tryParse(
      _precioController.text.replaceAll('.', ''),
    );
    if (parsedPrecio == null || parsedPrecio <= 0) {
      _mostrarError('Precio no válido. Ingrese un número válido');
      return;
    }

    if (_categoriaController.text.trim().isEmpty) {
      _mostrarError('Falta la categoría del producto');
      return;
    }

    if (_imagenBytes == null) {
      _mostrarError('Falta seleccionar una imagen');
      return;
    }

    setState(() => _subiendo = true);

    try {
      final storage = Supabase.instance.client.storage;
      final bucket = storage.from('juli3d');

      final path =
          'producto_${DateTime.now().millisecondsSinceEpoch}_${_nombreImagen ?? 'imagen.jpeg'}';

      await bucket.uploadBinary(
        path,
        _imagenBytes!,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = bucket.getPublicUrl(path);

      await Supabase.instance.client.from('juli3d').insert({
        'titulo': _tituloController.text.trim(),
        'precio': parsedPrecio,
        'descripcion': _descripcionController.text.trim(),
        'imagen_url': publicUrl,
        'categoria': _categoriaController.text.trim(),
      });

      // Limpiar formulario
      setState(() {
        _subiendo = false;
        _imagenBytes = null;
        _nombreImagen = null;
        _tituloController.clear();
        _precioController.clear();
        _descripcionController.clear();
        _categoriaController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto agregado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _subiendo = false);
      if (mounted) {
        _mostrarError('Error al guardar: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 36, 39),

      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppbar(),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: CatalogoHeaderWidget(text: 'Agregar nuevo producto'),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _tituloController,
                          decoration: InputDecoration(
                            labelText: 'Título',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 29, 36, 39),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _precioController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Precio',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 29, 36, 39),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descripcionController,
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 29, 36, 39),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _familiaController,
                          decoration: InputDecoration(
                            labelText: 'Familia',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 29, 36, 39),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _categoriaController,
                          decoration: InputDecoration(
                            labelText: 'Categoría ',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 29, 36, 39),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _seleccionarArchivo,
                          icon: const Icon(Icons.upload, color: Colors.white),
                          label: const Text(
                            'Seleccionar imagen',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_imagenBytes != null)
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _imagenBytes!,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _nombreImagen ?? 'Imagen seleccionada',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        const SizedBox(height: 24),
                        HoverAnimatedButton(
                          onPressed: _guardarProducto,
                          text: 'Guardar producto',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _categoriaController.dispose();
    _familiaController.dispose();
    super.dispose();
  }
}
