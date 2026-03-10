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
          appBar: AppBar(
            title: Text('Perfil: ${player.name}'),
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar y Nombre
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red.shade100,
                  child: Text(player.dorsal, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red)),
                ),
                const SizedBox(height: 15),
                Text(player.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Muestra los Partidos Jugados
                Card(
                  color: Colors.blue.shade50,
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.sports_soccer, color: Colors.blue, size: 30),
                    title: const Text('Partidos Jugados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    trailing: Text('${player.matchesPlayed}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                ),
                
                const SizedBox(height: 20),
                const Divider(height: 20, thickness: 1.5),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Rendimiento y Estadísticas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),

                // Lista dinámica de estadísticas con Porcentaje/Media por partido
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: player.stats.length,
                  itemBuilder: (context, index) {
                    String key = player.stats.keys.elementAt(index);
                    int totalValue = player.stats[key] ?? 0;
                    
                    // CÁLCULO DE LA MEDIA POR PARTIDO (Evitando dividir entre cero)
                    double average = player.matchesPlayed > 0 
                        ? totalValue / player.matchesPlayed 
                        : 0.0;

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        // Muestra el promedio con 2 decimales
                        subtitle: Text(
                          'Media: ${average.toStringAsFixed(2)} por partido', 
                          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)
                        ),
                        // Muestra el total a la derecha en grande
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('$totalValue', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}