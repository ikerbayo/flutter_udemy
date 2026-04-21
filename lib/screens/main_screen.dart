import 'package:flutter/material.dart';
import '../match_state.dart';
import 'player_profile_screen.dart';
import 'pre_match_config_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: matchState,
      builder: (context, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Plantilla Global', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Resumen de todos tus jugadores registrados.',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: matchState.players.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: matchState.players.length,
                            itemBuilder: (context, index) {
                              final player = matchState.players[index];
                              return _buildPlayerCard(context, player);
                            },
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreMatchConfigScreen()),
              );
            },
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.sports_soccer),
            label: const Text('Nuevo Partido'),
          ),
        );
      },
    );
  }

  Widget _buildPlayerCard(BuildContext context, dynamic player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlayerProfileScreen(player: player)),
          );
        },
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF667eea).withOpacity(0.1),
          child: Text(
            player.dorsal,
            style: const TextStyle(color: Color(0xFF667eea), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
        subtitle: Text(
          'Partidos: ${player.matchesPlayed} • Goles: ${player.goals}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_search, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text('No hay jugadores registrados todavía', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => matchState.loadAllData(),
          child: const Text('Sincronizar Datos'),
        )
      ],
    );
  }
}
