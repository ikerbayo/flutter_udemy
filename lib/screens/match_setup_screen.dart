import 'package:flutter/material.dart';
import '../match_state.dart';
import '../player.dart';
import 'live_match_screen.dart';

class MatchSetupScreen extends StatelessWidget {
  const MatchSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: matchState,
      builder: (context, child) {
        
        // --- ESCUDO ANTI-ERRORES PARA LOS DROPDOWNS ---
        // Si el valor guardado no coincide con la lista, elige el primero por defecto.
        // Esto evita el 100% de los pantallazos rojos "Assertion failed".
        String currentType = matchState.availableFormations.containsKey(matchState.matchType)
            ? matchState.matchType
            : matchState.availableFormations.keys.first;

        List<String> currentFormations = matchState.availableFormations[currentType]!;
        String currentFormation = currentFormations.contains(matchState.matchFormation)
            ? matchState.matchFormation
            : currentFormations.first;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Convocatoria Rápida'),
            backgroundColor: Colors.red.shade800,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              // --- 1. SELECTORES DE FORMACIÓN ---
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: DropdownButtonFormField<String>(
                        value: currentType, // Usamos la variable protegida
                        decoration: const InputDecoration(labelText: 'División', border: OutlineInputBorder()),
                        isExpanded: true,
                        items: matchState.availableFormations.keys.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11)))).toList(),
                        onChanged: (v) => matchState.changeMatchType(v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        value: currentFormation, // Usamos la variable protegida
                        decoration: const InputDecoration(labelText: 'Táctica', border: OutlineInputBorder()),
                        isExpanded: true,
                        items: currentFormations.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                        onChanged: (v) => matchState.changeFormation(v!),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('TOCA LOS CUADRADOS PARA CONVOCAR:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),

              // --- 2. CAMPO DE FÚTBOL VISUAL ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Stack(
                    children: [
                      // Líneas del campo (simplificadas)
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 2,
                          color: Colors.white54,
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white54, width: 2),
                          ),
                        ),
                      ),
                      // Filas de jugadores
                      Builder(
                        builder: (context) {
                          // Parsear formación (ej: "1-4-4-2" -> [1, 4, 4, 2])
                          List<int> formationRows = matchState.matchFormation
                              .split('-')
                              .map((e) => int.tryParse(e) ?? 0)
                              .toList();
                          
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(formationRows.length, (rowIndex) {
                              int playersInRow = formationRows[rowIndex];
                              
                              // Calcular índice base para esta fila
                              int baseIndex = 0;
                              for (int i = 0; i < rowIndex; i++) {
                                baseIndex += formationRows[i];
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(playersInRow, (colIndex) {
                                  int positionIndex = baseIndex + colIndex;
                                  Player? assignedPlayer = matchState.positionAssignments[positionIndex];

                                  return GestureDetector(
                                    onTap: () => _showPlayerSelectionSheet(context, positionIndex),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: assignedPlayer != null ? Colors.blue.shade900 : Colors.white24,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: assignedPlayer != null ? [const BoxShadow(color: Colors.black45, blurRadius: 5)] : [],
                                      ),
                                      child: Center(
                                        child: assignedPlayer != null
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(assignedPlayer.dorsal, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                                  Text(
                                                    assignedPlayer.name,
                                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              )
                                            : const Icon(Icons.add, color: Colors.white, size: 30),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ),

              // --- 3. BOTÓN DE EMPEZAR ---
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.sports_soccer, size: 28),
                  onPressed: matchState.positionAssignments.isEmpty ? null : () {
                    matchState.startNewMatch();
                    matchState.selectPlayer(matchState.currentMatchPlayers.first);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LiveMatchScreen()));
                  },
                  label: Text('EMPEZAR PARTIDO (${matchState.positionAssignments.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showPlayerSelectionSheet(BuildContext context, int positionIndex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        // Encontrar jugadores disponibles (no asignados o el actualmente asignado a esta posición)
        final alreadyAssignedIds = matchState.positionAssignments.values.map((p) => p.id).toSet();
        final currentAssignedInThisSlot = matchState.positionAssignments[positionIndex];
        
        // Excluimos a los que ya están asignados a OTRAS posiciones
        final availablePlayers = matchState.players.where((p) {
          if (currentAssignedInThisSlot?.id == p.id) return true;
          return !alreadyAssignedIds.contains(p.id);
        }).toList();

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Seleccionar Jugador', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (currentAssignedInThisSlot != null)
                    TextButton.icon(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      label: const Text('Quitar', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        matchState.removePlayerFromPosition(positionIndex);
                        Navigator.pop(ctx);
                      },
                    )
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: availablePlayers.isEmpty 
                  ? const Center(child: Text('No hay jugadores disponibles'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
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
                              color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(player.dorsal, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
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