import 'package:flutter/material.dart';
import '../match_state.dart';
import 'predictions_screen.dart';

class PreMatchConfigScreen extends StatefulWidget {
  const PreMatchConfigScreen({super.key});

  @override
  State<PreMatchConfigScreen> createState() => _PreMatchConfigScreenState();
}

class _PreMatchConfigScreenState extends State<PreMatchConfigScreen> {
  final TextEditingController _rivalController = TextEditingController();
  bool _isLocal = true;

  @override
  void dispose() {
    _rivalController.dispose();
    super.dispose();
  }

  void _continueToSetup() {
    final rivalName = _rivalController.text.trim().isEmpty 
        ? 'Rival Desconocido' 
        : _rivalController.text.trim();
        
    matchState.setMatchConfig(_isLocal, rivalName);
    
    // IMPORTANTE: Limpiar antes de configurar el nuevo partido
    matchState.currentMatchPlayers.clear();
    matchState.positionAssignments.clear();
    matchState.sessionStats.clear(); 
    matchState.selectedPlayer = null;

    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => const PredictionsScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Partido'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '¿Dónde Jugamos?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLocal ? Colors.green : Colors.grey.shade300,
                      foregroundColor: _isLocal ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        _isLocal = true;
                      });
                    },
                    child: const Text('LOCAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isLocal ? Colors.orange : Colors.grey.shade300,
                      foregroundColor: !_isLocal ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        _isLocal = false;
                      });
                    },
                    child: const Text('VISITANTE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Equipo Rival:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _rivalController,
              decoration: InputDecoration(
                hintText: 'Ej. FC Barcelona',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: const Icon(Icons.shield),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('CONTINUAR A LA PORRA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _continueToSetup,
            ),
          ],
        ),
      ),
    );
  }
}
