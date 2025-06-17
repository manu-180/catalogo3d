import 'package:catalogo3d/screens/agregar_productos_screen.dart';
import 'package:catalogo3d/screens/remover_productos_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const AgregarProductoScreen(),
    ),
    GoRoute(
      path: "/remover",
      builder: (context, state) => const RemoverProductoScreen(),
    ),
  ],
);
