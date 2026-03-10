import 'package:flutter/material.dart';
import '../match_state.dart';
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

              // --- 2. GRID DE JUGADORES (Convocatoria ultra rápida) ---
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, 
                    mainAxisSpacing: 10, 
                    crossAxisSpacing: 10,
                  ),
                  itemCount: matchState.players.length,
                  itemBuilder: (context, index) {
                    final player = matchState.players[index];
                    final isSelected = matchState.currentMatchPlayers.contains(player);
                    
                    return InkWell(
                      onTap: () => matchState.togglePlayerInMatch(player),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? Colors.green.shade900 : Colors.grey.shade400, width: 2),
                          boxShadow: isSelected ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(player.dorsal, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                            Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.black54)),
                          ],
                        ),
                      ),
                    );
                  },
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
                  onPressed: matchState.currentMatchPlayers.isEmpty ? null : () {
                    matchState.startNewMatch();
                    matchState.selectPlayer(matchState.currentMatchPlayers.first);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LiveMatchScreen()));
                  },
                  label: Text('EMPEZAR PARTIDO (${matchState.currentMatchPlayers.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}