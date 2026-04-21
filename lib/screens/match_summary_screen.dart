import 'package:flutter/material.dart';
import '../match_state.dart';
import '../player.dart';
import 'standings_screen.dart';

class MatchSummaryScreen extends StatefulWidget {
  final Map<String, dynamic>? matchData;

  const MatchSummaryScreen({super.key, this.matchData});

  @override
  State<MatchSummaryScreen> createState() => _MatchSummaryScreenState();
}

class _MatchSummaryScreenState extends State<MatchSummaryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final players = matchState.currentMatchPlayers;
    final homeScore = matchState.homeScore;
    final awayScore = matchState.awayScore;
    final rivalName = matchState.rivalName;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Resumen del Partido', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
              _buildFinalScore(homeScore, awayScore, rivalName),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rendimiento de los Jugadores',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                        ),
                        const SizedBox(height: 16),
                        _buildPlayersStatsList(players),
                        const SizedBox(height: 30),
                        _buildActions(context),
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
  }

  Widget _buildFinalScore(int home, int away, String rival) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTeamInfo(matchState.isLocal ? 'Mi Equipo' : rival, home),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'FT',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold),
            ),
          ),
          _buildTeamInfo(matchState.isLocal ? rival : 'Mi Equipo', away),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(String name, int score) {
    return Column(
      children: [
        Text(
          score.toString(),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(
          width: 100,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersStatsList(List<Player> players) {
    // Calculamos si hay goles manuales (ID 0 o IDs de "Jugador Fantasma")
    int manualGoals = 0;
    for (var event in matchState.recordedEvents) {
      final pid = event['playerId'];
      final isGhost = (pid == 0 || pid == matchState.teamGhostPlayerId);
      if (isGhost && event['tipo'] == 'Gol') {
        manualGoals++;
      }
    }

    return Column(
      children: [
        if (manualGoals > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.star, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Goles de Equipo (Manual)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text('Se han registrado $manualGoals goles sin asignar a un jugador específico.', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: players.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final player = players[index];
            final stats = matchState.sessionStats[player.id] ?? {};
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF667eea).withOpacity(0.1),
                    child: Text(player.dorsal, style: const TextStyle(color: Color(0xFF667eea), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        _buildCompactStatsRow(stats),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompactStatsRow(Map<String, int> stats) {
    List<Widget> chips = [];
    stats.forEach((key, value) {
      if (value > 0) {
        chips.add(
          Container(
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '${_getShortName(key)}: $value',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    });

    if (chips.isEmpty) {
      return const Text('Sin eventos destacados', style: TextStyle(fontSize: 11, color: Colors.grey));
    }

    return Wrap(children: chips);
  }

  String _getShortName(String key) {
    if (key == 'Gol') return 'G';
    if (key == 'Asistencia') return 'A';
    if (key == 'Tiro_Puerta') return 'T';
    if (key == 'Falta_Cometida') return 'F';
    return key.substring(0, 1).toUpperCase();
  }

  Widget _buildActions(BuildContext context) {
    Map<String, dynamic>? currentClub;
    if (matchState.currentTeamId != null) {
      for (var club in matchState.cachedClubs) {
        final clubId = club['id'];
        final teams = matchState.cachedTeams[clubId] ?? [];
        if (teams.any((t) => t['id'] == matchState.currentTeamId)) {
          currentClub = club;
          break;
        }
      }
    }

    return Column(
      children: [
        if (currentClub != null) ...[
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StandingsScreen(club: currentClub!)),
              );
            },
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('VER CLASIFICACIÓN ACTUALIZADA'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF667eea),
              minimumSize: const Size(double.infinity, 56),
              side: const BorderSide(color: Color(0xFF667eea)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('VOLVER AL INICIO', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
