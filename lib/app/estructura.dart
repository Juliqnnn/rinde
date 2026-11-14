import 'package:flutter/material.dart';
import 'package:rinde/funciones/inicio/inicio.dart';
import 'package:rinde/funciones/ventas/vender.dart';
import 'package:rinde/funciones/platos/pantallas/platos.dart';
import 'package:rinde/comun/tema/cenefa.dart';
class Estructura extends StatefulWidget {
  const Estructura({super.key});

  @override
  State<Estructura> createState() => _EstructuraState();
}

class _EstructuraState extends State<Estructura> {
  int _pestana = 0;

  final _pantallas = const [
    InicioPantalla(),
    VenderPantalla(),
    PlatosPantalla(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SafeArea(bottom: false, child: Cenefa()),
          Expanded(child: _pantallas[_pestana]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (i) => setState(() => _pestana = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            selectedIcon: Icon(Icons.shopping_basket),
            label: 'Vender',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Platos',
          ),
        ],
      ),
    );
  }
}