import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAppbar extends StatefulWidget {
  const CustomAppbar({super.key});

  @override
  State<CustomAppbar> createState() => _CustomAppbarState();
}

class _CustomAppbarState extends State<CustomAppbar> {
  bool _isMenuOpen = false;
  List<String> _familias = [];

  final List<Map<String, String>> _menuItems = [
    {'label': 'Agregar', 'route': '/'},
    {'label': 'Remover', 'route': '/remover'},
    // {'label': 'Contacto', 'route': '/contacto'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final color = Theme.of(context).colorScheme;
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: color.primary,
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.02,
            horizontal: size.width * 0.03,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => context.push('/'),
                  child: Image.asset(
                    'assets/icon/logoappbar.png',
                    width: size.height * 0.2,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(), // Para que el primer lado no tenga nada

              Row(
                children: [
                  _NavTextButton(
                    label: 'Agregar',
                    route: '/',
                    isActive: currentRoute == '/',
                    onTap: () => context.push('/'),
                  ),
                  SizedBox(width: size.width * 0.01),
                  _NavTextButton(
                    label: 'Remover',
                    route: '/remover',
                    isActive: currentRoute == '/remover',
                    onTap: () => context.push('/remover'),
                  ),
                  SizedBox(width: size.width * 0.01),

                  _NavTextButton(
                    label: 'Actualizar',
                    route: '/actualizar',
                    isActive: currentRoute == '/actualizar',
                    onTap: () => context.push('/actualizar'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Menú desplegable mobile
        if (!isWide && _isMenuOpen)
          FadeInDown(
            child: Container(
              color: color.primary,
              width: double.infinity,
              padding: EdgeInsets.only(bottom: size.height * 0.03),
              child: Column(
                children: [
                  ..._menuItems.map(
                    (item) => ListTile(
                      title: Text(
                        item['label']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        context.push(item['route']!);
                        setState(() => _isMenuOpen = false);
                      },
                    ),
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Catálogo',
                      style: TextStyle(color: Colors.white),
                    ),
                    children:
                        _familias
                            .map(
                              (f) => ListTile(
                                title: Text(
                                  f,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                onTap: () {
                                  context.push(
                                    '/catalogo?familia=${Uri.encodeComponent(f)}',
                                  );
                                  setState(() => _isMenuOpen = false);
                                },
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _NavTextButton extends StatefulWidget {
  final String label;
  final String route;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTextButton({
    required this.label,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavTextButton> createState() => _NavTextButtonState();
}

class _NavTextButtonState extends State<_NavTextButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = Colors.grey.shade300;
    final Color hoverColor = Colors.white;
    final isActive = widget.isActive;
    final Color finalColor = (_isHovering || isActive) ? hoverColor : baseColor;
    final double textWidth = _calcularAnchoTexto(context, widget.label);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(color: finalColor, fontSize: 24),
                child: Text(widget.label),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 2,
                width: _isHovering ? textWidth : 0,
                color: hoverColor,
                curve: Curves.easeInOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calcularAnchoTexto(BuildContext context, String texto) {
    const double fontSize = 24;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: texto, style: const TextStyle(fontSize: fontSize)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }
}
