import 'package:flutter/material.dart';
import '../match_state.dart';

class LiveMatchScreen extends StatelessWidget {
  const LiveMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: matchState,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Partido en Vivo'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            toolbarHeight: 40, // Más baja para ganar espacio
          ),
          body: Column(
            children: [
              // 1. SELECTOR DE JUGADORES (Muy compacto)
              Container(
                height: 160, // Altura fija para que no coma mucha pantalla
                color: Colors.grey.shade200,
                child: GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, // 6 jugadores por fila para que quepan todos
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: matchState.currentMatchPlayers.length,
                  itemBuilder: (context, index) {
                    final player = matchState.currentMatchPlayers[index];
                    final isSelected = matchState.selectedPlayer?.id == player.id;
                    return InkWell(
                      onTap: () => matchState.selectPlayer(player),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(player.dorsal, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. PANEL DE ESTADÍSTICAS (Botones grandes)
              Expanded(
                child: matchState.selectedPlayer == null
                    ? const Center(child: Text('Selecciona un jugador'))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Dorsal ${matchState.selectedPlayer!.dorsal}: ${matchState.selectedPlayer!.name}', 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(), // Evita el scroll, fuerza a que quepa
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, 
                                  childAspectRatio: 1.8, // Botones más anchos que altos para que quepan 4-6
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: matchState.statCategories.length,
                                itemBuilder: (context, index) {
                                  final stat = matchState.statCategories[index];
                                  final valor = matchState.sessionStats[matchState.selectedPlayer!.id]?[stat] ?? 0;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade700,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: InkWell(
                                      onTap: () => matchState.incrementStat(stat),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(stat, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                Text('$valor', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: 0, bottom: 0,
                                            child: IconButton(
                                              icon: const Icon(Icons.remove_circle, color: Colors.white70, size: 20),
                                              onPressed: () => matchState.decrementStat(stat),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}