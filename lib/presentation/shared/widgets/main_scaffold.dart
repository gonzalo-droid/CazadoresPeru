import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Inicio',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: 'Buscar',
    ),
    
    /* TODO: Actualizar cuando busque un fin para ello
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: 'Mapa',
    ),
    */
    NavigationDestination(
      icon: Icon(Icons.bookmark_outline),
      selectedIcon: Icon(Icons.bookmark),
      label: 'Guardados',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Perfil',
    ),
  ];

  static const _routes = [
    AppRoutes.home,
    AppRoutes.search,
    AppRoutes.map,
    AppRoutes.favorites,
    AppRoutes.profile,
  ];

  int _locationToIndex(String location) {
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i]) &&
          (_routes[i] != '/' || location == '/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i != index) {
            context.go(_routes[i]);
          }
        },
        destinations: _destinations,
      ),
    );
  }
}
