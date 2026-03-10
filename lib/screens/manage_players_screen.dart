import 'package:flutter/material.dart';
import '../match_state.dart';

class ManagePlayersScreen extends StatefulWidget {
  const ManagePlayersScreen({super.key});

  @override
  State<ManagePlayersScreen> createState() => _ManagePlayersScreenState();
}

class _ManagePlayersScreenState extends State<ManagePlayersScreen> {
  // Ahora necesitamos dos controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dorsalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plantilla')),
      body: ListenableBuilder(
        listenable: matchState,
        builder: (context, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Campo para el dorsal (más pequeño)
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _dorsalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Nº (Ej: 10)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Campo para el nombre (más grande)
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(hintText: 'Nombre (Ej: Pedro)'),
                        onSubmitted: (value) => _addPlayer(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue, size: 36),
                      onPressed: _addPlayer,
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: matchState.players.length,
                  itemBuilder: (context, index) {
                    final player = matchState.players[index];
                    return ListTile(
                      // Mostramos el dorsal de forma bonita en un círculo
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: Text(
                          player.dorsal, 
                          style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold)
                        ),
                      ),
                      title: Text(player.name),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addPlayer() {
    // Comprobamos que ambos campos tengan texto antes de guardar
    if (_nameController.text.trim().isNotEmpty && _dorsalController.text.trim().isNotEmpty) {
      matchState.addPlayer(_nameController.text.trim(), _dorsalController.text.trim());
      _nameController.clear();
      _dorsalController.clear();
    }
  }
}