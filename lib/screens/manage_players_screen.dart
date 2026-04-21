import 'package:flutter/material.dart';
import '../api_service.dart';
import '../match_state.dart';
import '../player.dart';
import 'player_profile_screen.dart';

class ManagePlayersScreen extends StatefulWidget {
  final Map<String, dynamic> team;
  const ManagePlayersScreen({super.key, required this.team});

  @override
  State<ManagePlayersScreen> createState() => _ManagePlayersScreenState();
}

class _ManagePlayersScreenState extends State<ManagePlayersScreen> {
  List<dynamic> _players = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      // Usamos matchState para obtener los jugadores con estadísticas agregadas
      await matchState.selectTeam(widget.team['id']);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Jugadores: ${widget.team['nombre']}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${_players.length} jugadores',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.person_add_alt_1, color: Colors.white.withOpacity(0.8)),
                  ],
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
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF667eea)))
                    : _players.isEmpty && matchState.players.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: matchState.players.where((p) => p.name.toUpperCase() != 'EQUIPO' && p.dorsal != '0').length,
                          itemBuilder: (context, index) {
                            final filteredPlayers = matchState.players.where((p) => p.name.toUpperCase() != 'EQUIPO' && p.dorsal != '0').toList();
                            final player = filteredPlayers[index];
                            return _buildPlayerCard(player);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF667eea).withOpacity(0.1),
          child: ClipOval(
            child: player.foto != null 
              ? Image.network(
                  player.foto!,
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Color(0xFF667eea)),
                )
              : const Icon(Icons.person, color: Color(0xFF667eea)),
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
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text('No hay jugadores en este equipo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}