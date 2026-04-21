import 'package:flutter/material.dart';
import '../player.dart';
import '../match_state.dart';

class PlayerProfileScreen extends StatelessWidget {
  final Player player;

  const PlayerProfileScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: matchState,
      builder: (context, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text('Perfil: ${player.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  _buildProfileHeader(player),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatSummary(player),
                            const SizedBox(height: 32),
                            const Text(
                              'Estadísticas Detalladas',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                            ),
                            const SizedBox(height: 16),
                            _buildStatsList(player),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Player player) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Text(
                  player.dorsal,
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            if (player.foto != null)
              Positioned.fill(
                child: ClipOval(
                  child: Image.network(
                    player.foto!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        player.dorsal,
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          player.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          player.posicionPrincipal ?? 'Sin posición',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatSummary(Player player) {
    return Row(
      children: [
        _buildSummaryItem('Partidos', '${player.matchesPlayed}', Icons.sports_soccer, Colors.blue),
        const SizedBox(width: 16),
        _buildSummaryItem('Goles', '${player.goals}', Icons.star, Colors.orange),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsList(Player player) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: player.stats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        String key = player.stats.keys.elementAt(index);
        int totalValue = player.stats[key] ?? 0;
        double average = player.matchesPlayed > 0 ? totalValue / player.matchesPlayed : 0.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(key, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                    Text(
                      'Media: ${average.toStringAsFixed(2)} por partido', 
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12)
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$totalValue', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF667eea))),
                  const Text('TOTAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}