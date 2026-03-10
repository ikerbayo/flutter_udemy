import 'package:flutter/material.dart';
import '../match_state.dart';
import '../player.dart';
import 'match_setup_screen.dart';

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key});

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  int _localScore = 0;
  int _visitorScore = 0;
  final List<Player> _selectedScorers = [];

  void _continueToSetup() {
    matchState.setMatchPredictions(_localScore, _visitorScore, _selectedScorers);
    
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => const MatchSetupScreen())
    );
  }

  void _toggleScorer(Player player) {
    setState(() {
      if (_selectedScorers.contains(player)) {
        _selectedScorers.remove(player);
      } else {
        _selectedScorers.add(player);
      }
    });
  }

  Widget _buildScoreControl(String teamName, int score, VoidCallback onMinus, VoidCallback onPlus, bool isLocalColor) {
    return Column(
      children: [
        Text(teamName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isLocalColor ? Colors.red.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isLocalColor ? Colors.red : Colors.grey.shade400, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.black54),
                onPressed: onMinus,
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text('$score', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black87),
                onPressed: onPlus,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localTeam = matchState.isLocal ? 'Redtable' : matchState.rivalName;
    final visitorTeam = matchState.isLocal ? matchState.rivalName : 'Redtable';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('⚽ La Porra'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. MARCADOR EXACTO
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('RESULTADO EXACTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildScoreControl(localTeam, _localScore, () {
                      if (_localScore > 0) setState(() => _localScore--);
                    }, () {
                      setState(() => _localScore++);
                    }, matchState.isLocal)),
                    
                    const Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
                    ),
                    
                    Expanded(child: _buildScoreControl(visitorTeam, _visitorScore, () {
                      if (_visitorScore > 0) setState(() => _visitorScore--);
                    }, () {
                      setState(() => _visitorScore++);
                    }, !matchState.isLocal)),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1),
          
          // 2. GOLEADORES
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sports_soccer, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text('¿Quién marcará gol?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${_selectedScorers.length} Elegidos', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: matchState.players.length,
                      itemBuilder: (context, index) {
                        final player = matchState.players[index];
                        final isSelected = _selectedScorers.contains(player);
                        
                        return InkWell(
                          onTap: () => _toggleScorer(player),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green.shade100 : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300, width: 2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.green : Colors.grey.shade200,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(player.dorsal, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 3. BOTÓN CONTINUAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              icon: const Icon(Icons.check_circle, size: 28),
              label: const Text('CONFIRMAR PORRA Y CONVOCAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _continueToSetup,
            ),
          ),
        ],
      ),
    );
  }
}
