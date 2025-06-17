import 'package:catalogo3d/widgets/appbar.dart';
import 'package:catalogo3d/widgets/catalogo_header.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoverProductoScreen extends StatefulWidget {
  const RemoverProductoScreen({super.key});

  @override
  State<RemoverProductoScreen> createState() => _RemoverProductoScreenState();
}

class _RemoverProductoScreenState extends State<RemoverProductoScreen> {
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

    final todasFamilias = <String>{
      'Todos',
      ...data.map((e) => (e['familia'] ?? '').toString()),
    };
    final todasCategorias = <String>{
      'Todos',
      ...data.map((e) => (e['categoria'] ?? '').toString()),
    };

    data.sort((a, b) {
      final tituloA = (a['titulo'] ?? '').toString().toLowerCase();
      final tituloB = (b['titulo'] ?? '').toString().toLowerCase();
      return tituloA.compareTo(tituloB);
    });
    setState(() {
      productos = data;
      familias = todasFamilias.where((e) => e.trim().isNotEmpty).toList();
      categorias = todasCategorias.where((e) => e.trim().isNotEmpty).toList();
      if (!familias.contains(familiaSeleccionada)) {
        familiaSeleccionada = 'Todos';
      }
      if (!categorias.contains(categoriaSeleccionada)) {
        categoriaSeleccionada = 'Todos';
      }
    });
  }

  Future<void> _eliminarProducto(int id) async {
    await Supabase.instance.client.from('juli3d').delete().eq('id', id);
    _cargarProductos(); // Recargar lista actualizada
  }

  List<Map<String, dynamic>> get _productosFiltrados {
    return productos.where((producto) {
      final familia = producto['familia'] ?? '';
      final categoria = producto['categoria'] ?? '';
      final coincideFamilia =
          familiaSeleccionada == 'Todos' || familia == familiaSeleccionada;
      final coincideCategoria =
          categoriaSeleccionada == 'Todos' ||
          categoria == categoriaSeleccionada;
      return coincideFamilia && coincideCategoria;
    }).toList();
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
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Center(
                        child: const CatalogoHeaderWidget(
                          text: 'Remover productos',
                        ),
                      ),
                      const SizedBox(height: 50),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: familiaSeleccionada,
                              items:
                                  familias
                                      .map(
                                        (f) => DropdownMenuItem(
                                          value: f,
                                          child: Text(f),
                                        ),
                                      )
                                      .toList(),
                              dropdownColor: Colors.black,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Familia',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              onChanged: (valor) {
                                if (valor != null) {
                                  setState(() => familiaSeleccionada = valor);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: categoriaSeleccionada,
                              items:
                                  categorias
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ),
                                      )
                                      .toList(),
                              dropdownColor: Colors.black,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Categoría',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              onChanged: (valor) {
                                if (valor != null) {
                                  setState(() => categoriaSeleccionada = valor);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_productosFiltrados.isEmpty)
                        const Center(
                          child: Text(
                            'No hay productos para mostrar',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _productosFiltrados.length,
                          itemBuilder: (context, index) {
                            final producto = _productosFiltrados[index];
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text(
                                          '¿Eliminar producto?',
                                        ),
                                        content: Text(
                                          '¿Estás seguro de que querés eliminar "${producto['titulo']}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                          ),
                                          FilledButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await _eliminarProducto(
                                                producto['id'],
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    '✅ Producto eliminado correctamente',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Eliminar',
                                             
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              child: Card(
                                color:
                                    _hoveredIndex == index
                                        ? const Color.fromARGB(255, 50, 55, 58)
                                        : const Color.fromARGB(255, 39, 46, 49),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: ListTile(
                                  leading: Image.network(
                                    producto['imagen_url'] ?? '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              color: Colors.white70,
                                            ),
                                  ),
                                  title: Text(
                                    '${producto['titulo'] ?? ''} - \$${producto['precio'] ?? '0'}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  trailing: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
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
