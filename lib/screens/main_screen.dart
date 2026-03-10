import 'package:flutter/material.dart';
import '../match_state.dart';
import 'manage_players_screen.dart';
import 'pre_match_config_screen.dart';
import 'player_profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: matchState,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('LOLOGOL - Plantilla'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManagePlayersScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: matchState.players.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No hay jugadores.'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Forzar carga de los jugadores por defecto y notificar
                          matchState.loadDefaultPlayers();
                        },
                        child: const Text('Cargar Jugadores de la Selección'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: matchState.players.length,
                  itemBuilder: (context, index) {
                    final player = matchState.players[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: Text(
                          player.dorsal,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Partidos Jugados: ${player.matchesPlayed}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerProfileScreen(player: player),
                          ),
                        );
                      },
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (matchState.players.isEmpty) return;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreMatchConfigScreen()),
              );
            },
            icon: const Icon(Icons.sports_soccer),
            label: const Text('Nuevo Partido'),
          ),
        );
      },
    );
  }
}
