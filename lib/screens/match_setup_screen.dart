import 'package:flutter/material.dart';
import '../match_state.dart';
import '../player.dart';
import 'live_match_screen.dart';
import '../api_service.dart';

class MatchSetupScreen extends StatelessWidget {
  const MatchSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: matchState,
      builder: (context, child) {
        String currentType = matchState.availableFormations.containsKey(matchState.matchType)
            ? matchState.matchType
            : matchState.availableFormations.keys.first;

        List<String> currentFormations = matchState.availableFormations[currentType]!;
        String currentFormation = currentFormations.contains(matchState.matchFormation)
            ? matchState.matchFormation
            : currentFormations.first;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Convocatoria Rápida', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  _buildFormationSelectors(context, currentType, currentFormation, currentFormations),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Toca las posiciones para asignar jugadores',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333)),
                            ),
                          ),
                          Expanded(child: _buildFootballField(context)),
                          _buildStartButton(context),
                        ],
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

  Widget _buildFormationSelectors(BuildContext context, String currentType, String currentFormation, List<String> currentFormations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _buildDropdown(
              label: 'División',
              value: currentType,
              items: matchState.availableFormations.keys.toList(),
              onChanged: (v) => matchState.changeMatchType(v!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: _buildDropdown(
              label: 'Táctica',
              value: currentFormation,
              items: currentFormations,
              onChanged: (v) => matchState.changeFormation(v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: const Color(0xFF764ba2),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFootballField(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2d5a27), // Verde hierba más oscuro/premium
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          // Líneas del campo premium
          CustomPaint(
            size: Size.infinite,
            painter: FieldPainter(),
          ),
          // Jugadores
          Builder(
            builder: (context) {
              List<int> formationRows = matchState.matchFormation.split('-').map((e) => int.tryParse(e) ?? 0).toList();
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(formationRows.length, (rowIndex) {
                  int playersInRow = formationRows[rowIndex];
                  int baseIndex = 0;
                  for (int i = 0; i < rowIndex; i++) baseIndex += formationRows[i];

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(playersInRow, (colIndex) {
                      int positionIndex = baseIndex + colIndex;
                      Player? assignedPlayer = matchState.positionAssignments[positionIndex];

                      return GestureDetector(
                        onTap: () => _showPlayerSelectionSheet(context, positionIndex),
                        child: _buildPlayerSlot(assignedPlayer),
                      );
                    }),
                  );
                }),
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSlot(Player? player) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: player != null ? const Color(0xFF667eea) : Colors.black12,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: player != null ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))] : [],
      ),
      child: Center(
        child: player != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(player.dorsal, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      player.name,
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : const Icon(Icons.add, color: Colors.white54, size: 24),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    bool canStart = matchState.positionAssignments.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: const Color(0xFF667eea).withOpacity(0.4),
        ),
        onPressed: !canStart ? null : () async {
          if (matchState.currentTeamId != null) {
             final homeId = matchState.isLocal ? matchState.currentTeamId! : (matchState.rivalTeamId ?? matchState.currentTeamId!);
             final matchId = await apiService.createMatch(
               homeId,
               teamAwayId: matchState.isLocal ? matchState.rivalTeamId : null,
               rivalNombre: (matchState.rivalTeamId == null) ? matchState.rivalName : null,
               fecha: DateTime.now().toIso8601String(),
             );
             matchState.currentMatchId = matchId;
          }
          matchState.startNewMatch();
          matchState.selectPlayer(matchState.currentMatchPlayers.first);
          if (context.mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LiveMatchScreen()));
          }
        },
        child: Text(
          'EMPEZAR PARTIDO (${matchState.positionAssignments.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  void _showPlayerSelectionSheet(BuildContext context, int positionIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final alreadyAssignedIds = matchState.positionAssignments.values.map((p) => p.id).toSet();
        final currentAssignedInThisSlot = matchState.positionAssignments[positionIndex];
        final availablePlayers = matchState.players.where((p) {
          // Filtrar al jugador fantasma "EQUIPO" para que no se pueda seleccionar
          if (p.name.toUpperCase() == 'EQUIPO' || p.dorsal == '0') return false;
          
          if (currentAssignedInThisSlot?.id == p.id) return true;
          return !alreadyAssignedIds.contains(p.id);
        }).toList();

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Convocar Jugador', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                  if (currentAssignedInThisSlot != null)
                    TextButton.icon(
                      icon: const Icon(Icons.person_remove_outlined, color: Colors.red, size: 18),
                      label: const Text('Descartar', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        matchState.removePlayerFromPosition(positionIndex);
                        Navigator.pop(ctx);
                      },
                    )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: availablePlayers.isEmpty 
                  ? const Center(child: Text('No hay más jugadores disponibles'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: availablePlayers.length,
                      itemBuilder: (context, index) {
                        final player = availablePlayers[index];
                        final isSelected = currentAssignedInThisSlot?.id == player.id;
                        return InkWell(
                          onTap: () {
                            matchState.assignPlayerToPosition(positionIndex, player);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF667eea).withOpacity(0.1) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? const Color(0xFF667eea) : Colors.grey.shade200, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(player.dorsal, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF667eea) : const Color(0xFF333333))),
                                Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Línea central
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    
    // Círculo central
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 50, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 2, paint..style = PaintingStyle.fill);

    // Áreas (arriba y abajo)
    _drawArea(canvas, size, paint..style = PaintingStyle.stroke, true);
    _drawArea(canvas, size, paint, false);
  }

  void _drawArea(Canvas canvas, Size size, Paint paint, bool top) {
    double y = top ? 0 : size.height;
    double h = top ? 60 : -60;
    
    // Área grande
    canvas.drawRect(Rect.fromLTWH(size.width * 0.2, y, size.width * 0.6, h), paint);
    // Área pequeña
    canvas.drawRect(Rect.fromLTWH(size.width * 0.35, y, size.width * 0.3, h / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}