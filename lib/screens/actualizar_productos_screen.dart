import 'package:catalogo3d/widgets/appbar.dart';
import 'package:catalogo3d/widgets/catalogo_header.dart';
import 'package:catalogo3d/widgets/editar_product_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActualizarProductoScreen extends StatefulWidget {
  const ActualizarProductoScreen({super.key});

  @override
  State<ActualizarProductoScreen> createState() => _ActualizarProductoScreenState();
}

class _ActualizarProductoScreenState extends State<ActualizarProductoScreen> {
  String familiaSeleccionada = 'Todos';
  String categoriaSeleccionada = 'Todos';
  int? _hoveredIndex;

  List<Map<String, dynamic>> productos = [];
  List<String> familias = ['Todos'];
  List<String> categorias = ['Todos'];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final response = await Supabase.instance.client.from('juli3d').select('*');
    final data = List<Map<String, dynamic>>.from(response);

    final todasFamilias = <String>{'Todos', ...data.map((e) => (e['familia'] ?? '').toString())};
    final todasCategorias = <String>{'Todos', ...data.map((e) => (e['categoria'] ?? '').toString())};

    data.sort((a, b) => (a['titulo'] ?? '').toString().toLowerCase().compareTo((b['titulo'] ?? '').toString().toLowerCase()));
    setState(() {
      productos = data;
      familias = todasFamilias.where((e) => e.trim().isNotEmpty).toList();
      categorias = todasCategorias.where((e) => e.trim().isNotEmpty).toList();
      if (!familias.contains(familiaSeleccionada)) familiaSeleccionada = 'Todos';
      if (!categorias.contains(categoriaSeleccionada)) categoriaSeleccionada = 'Todos';
    });
  }

  List<Map<String, dynamic>> get _productosFiltrados {
    return productos.where((producto) {
      final familia = producto['familia'] ?? '';
      final categoria = producto['categoria'] ?? '';
      return (familiaSeleccionada == 'Todos' || familia == familiaSeleccionada) &&
             (categoriaSeleccionada == 'Todos' || categoria == categoriaSeleccionada);
    }).toList();
  }

  void _abrirModalActualizar(Map<String, dynamic> producto) async {
  await showDialog(
    context: context,
    builder: (_) => EditarProductoDialog(
      producto: producto,
      onActualizado: _cargarProductos,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 36, 39),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppbar(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const Center(child: CatalogoHeaderWidget(text: 'Actualizar productos')),
                      const SizedBox(height: 50),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: familiaSeleccionada,
                              items: familias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                              dropdownColor: Colors.black,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Familia', labelStyle: TextStyle(color: Colors.white)),
                              onChanged: (valor) {
                                if (valor != null) setState(() => familiaSeleccionada = valor);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: categoriaSeleccionada,
                              items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              dropdownColor: Colors.black,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Categoría', labelStyle: TextStyle(color: Colors.white)),
                              onChanged: (valor) {
                                if (valor != null) setState(() => categoriaSeleccionada = valor);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_productosFiltrados.isEmpty)
                        const Center(
                          child: Text('No hay productos para mostrar', style: TextStyle(color: Colors.white70)),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _productosFiltrados.length,
                          itemBuilder: (context, index) {
                            final producto = _productosFiltrados[index];
                            return GestureDetector(
                              onTap: () => _abrirModalActualizar(producto),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                onEnter: (_) => setState(() => _hoveredIndex = index),
                                onExit: (_) => setState(() => _hoveredIndex = null),
                                child: Card(
                                  color: _hoveredIndex == index
                                      ? const Color.fromARGB(255, 50, 55, 58)
                                      : const Color.fromARGB(255, 39, 46, 49),
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  child: ListTile(
                                    leading: Image.network(
                                      producto['imagen_url'] ?? '',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image, color: Colors.white70),
                                    ),
                                    title: Text(
                                      '${producto['titulo'] ?? ''} - \$${producto['precio'] ?? '0'}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    trailing: const Icon(Icons.autorenew, color: Color.fromARGB(255, 83, 112, 126)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
