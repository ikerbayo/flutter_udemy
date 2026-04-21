import 'package:flutter/material.dart';
import '../match_state.dart';
import '../api_service.dart';
import 'match_summary_screen.dart';

class LiveMatchScreen extends StatelessWidget {
  const LiveMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String homeTitle = matchState.isLocal ? 'Mí Equipo' : matchState.rivalTeamName;
    String awayTitle = matchState.isLocal ? matchState.rivalTeamName : 'Mí Equipo';

    return ListenableBuilder(
      listenable: matchState,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1a1a2e), // Fondo oscuro profundo
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            title: const Text('Partido en Vivo', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              TextButton.icon(
                onPressed: () => _confirmEndMatch(context),
                icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                label: const Text('FINALIZAR', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildScoreboard(homeTitle, awayTitle),
              const SizedBox(height: 10),
              Expanded(
                child: _buildActionArea(context),
              ),
              _buildPlayerBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreboard(String homeTitle, String awayTitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildScoreColumn(homeTitle, matchState.homeScore, true),
          _buildTimerColumn(),
          _buildScoreColumn(awayTitle, matchState.awayScore, false),
        ],
      ),
    );
  }

  Widget _buildScoreColumn(String name, int score, bool isHome) {
    bool isUserTeam = (isHome == matchState.isLocal);
    return Column(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            name, 
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
            maxLines: 1, overflow: TextOverflow.ellipsis
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text('$score', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildScoreBtn(Icons.remove, () => isUserTeam ? matchState.recordUserGoal(false) : matchState.recordRivalGoal(false)),
            const SizedBox(width: 8),
            _buildScoreBtn(Icons.add, () => isUserTeam ? matchState.recordUserGoal(true) : matchState.recordRivalGoal(true)),
          ],
        )
      ],
    );
  }

  Widget _buildScoreBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white70, size: 16),
      ),
    );
  }

  Widget _buildTimerColumn() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(matchState.formattedTime, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text(matchState.millisecondsText, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTimerBtn(Icons.replay_10, () => matchState.adjustTime(-10)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => matchState.isTimerRunning ? matchState.pauseTimer() : matchState.startTimer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                  matchState.isTimerRunning ? Icons.pause : Icons.play_arrow,
                  color: const Color(0xFF667eea),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildTimerBtn(Icons.forward_10, () => matchState.adjustTime(10)),
          ],
        )
      ],
    );
  }

  Widget _buildTimerBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: Colors.white54, size: 20),
    );
  }

  Widget _buildActionArea(BuildContext context) {
    if (matchState.selectedPlayer == null) {
      return const Center(child: Text('Selecciona un jugador para marcar estadísticas', style: TextStyle(color: Colors.white38)));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF667eea),
                child: Text(matchState.selectedPlayer!.dorsal, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Text(matchState.selectedPlayer!.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: matchState.statCategories.length,
            itemBuilder: (context, index) {
              final stat = matchState.statCategories[index];
              final label = matchState.statLabels[stat] ?? stat;
              final valor = matchState.sessionStats[matchState.selectedPlayer!.id]?[stat] ?? 0;
              
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: InkWell(
                  onTap: () => matchState.incrementStat(stat),
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(label.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text('$valor', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 4, bottom: 4,
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white24, size: 20),
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
    );
  }

  Widget _buildPlayerBar() {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: matchState.currentMatchPlayers.where((p) => p.name.toUpperCase() != 'EQUIPO' && p.dorsal != '0').length,
        itemBuilder: (context, index) {
          final filteredPlayers = matchState.currentMatchPlayers.where((p) => p.name.toUpperCase() != 'EQUIPO' && p.dorsal != '0').toList();
          final player = filteredPlayers[index];
          bool isSelected = matchState.selectedPlayer?.id == player.id;
          return GestureDetector(
            onTap: () => matchState.selectPlayer(player),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF667eea) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? Colors.white24 : Colors.transparent),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(player.dorsal, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isSelected ? 20 : 16)),
                  Text(player.name, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 9), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmEndMatch(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a40),
        title: const Text('¿Finalizar Partido?', style: TextStyle(color: Colors.white)),
        content: const Text('Se guardarán las estadísticas y se cerrará el partido.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCELAR', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('SÍ, FINALIZAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    ) ?? false;

    if (confirm) {
      if (matchState.recordedEvents.isNotEmpty) {
        await apiService.syncEvents(matchState.recordedEvents);
      }
      if (matchState.currentMatchId != null) {
        await apiService.updateMatchStatus(matchState.currentMatchId!, 'Finalizado');
      }
      
      if (context.mounted) {
        // En lugar de hacer pop, vamos a la pantalla de resumen
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const MatchSummaryScreen())
        );
      }
    }
  }
}