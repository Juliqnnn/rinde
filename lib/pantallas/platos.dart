import 'package:flutter/material.dart';
import 'ingredientes.dart';

class PlatosPantalla extends StatefulWidget {
  const PlatosPantalla({super.key});

  @override
  State<PlatosPantalla> createState() => _PlatosPantallaState();
}

class _PlatosPantallaState extends State<PlatosPantalla> {
  int _vista = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Platos')),
                ButtonSegment(value: 1, label: Text('Ingredientes')),
              ],
              selected: {_vista},
              onSelectionChanged: (s) => setState(() => _vista = s.first),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _vista == 0
                ? const Center(child: Text('Aquí cargarás tus platos.'))
                : const IngredientesPantalla(),
          ),
        ],
      ),
    );
  }
}