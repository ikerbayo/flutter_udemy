import 'package:flutter/material.dart';
import '../api_service.dart';

class StandingsScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  const StandingsScreen({super.key, required this.club});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  List<dynamic> _standings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStandings();
  }

  Future<void> _loadStandings() async {
    try {
      final standings = await apiService.getStandingsByClub(widget.club['id']);
      setState(() {
        _standings = standings;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar tabla: $e')));
      }
    }
  }

  void _showMatchHistory(int teamId, String teamName) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MatchHistoryBottomSheet(teamId: teamId, teamName: teamName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Clasificación: ${widget.club['nombre']}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Toca un equipo para ver su historial detallado de partidos.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
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
                    : _standings.isEmpty
                      ? const Center(child: Text('No hay datos disponibles'))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                                columnSpacing: 18,
                                horizontalMargin: 12,
                                columns: const [
                                  DataColumn(label: Text('EQUIPO', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF667eea)))),
                                  DataColumn(label: Text('FORMA', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF667eea)))),
                                  DataColumn(label: Text('PJ', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('PTS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                                  DataColumn(label: Text('V', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('E', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('D', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('GF', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('GC', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: _standings.map((s) {
                                  final List<dynamic> lastResults = s['lastResults'] ?? [];
                                  
                                  return DataRow(
                                    onSelectChanged: (_) => _showMatchHistory(s['teamId'], s['teamNombre'] ?? 'Equipo'),
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            const Icon(Icons.shield, size: 16, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text(s['teamNombre'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                                          ],
                                        )
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: lastResults.map((r) {
                                            Color color = Colors.grey;
                                            if (r == 'V') color = Colors.green;
                                            if (r == 'E') color = Colors.orange;
                                            if (r == 'D') color = Colors.red;
                                            
                                            return Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 1),
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(r, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      ),
                                      DataCell(Text('${s['pj']}')),
                                      DataCell(Text('${s['puntos']}', style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold))),
                                      DataCell(Text('${s['pg']}', style: const TextStyle(color: Colors.green))),
                                      DataCell(Text('${s['pe']}', style: const TextStyle(color: Colors.orange))),
                                      DataCell(Text('${s['pp']}', style: const TextStyle(color: Colors.red))),
                                      DataCell(Text('${s['gf']}')),
                                      DataCell(Text('${s['gc']}')),
                                    ]
                                  );
                                }).toList(),
                              ),
                            ),
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
}

class _MatchHistoryBottomSheet extends StatelessWidget {
  final int teamId;
  final String teamName;

  const _MatchHistoryBottomSheet({required this.teamId, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF667eea)),
                const SizedBox(width: 12),
                Text('Historial: $teamName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: apiService.getMatchHistory(teamId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF667eea)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final matches = snapshot.data ?? [];
                if (matches.isEmpty) {
                  return const Center(child: Text('No hay partidos finalizados.'));
                }
                
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: matches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final m = matches[index];
                    final homeGoles = m['teamHomeGoles'] ?? 0;
                    final awayGoles = m['teamAwayGoles'] ?? 0;
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            m['fecha'].toString().split('T').first, 
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  m['teamHomeNombre'], 
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: m['teamHomeNombre'] == teamName ? FontWeight.bold : FontWeight.normal,
                                    color: m['teamHomeNombre'] == teamName ? const Color(0xFF667eea) : const Color(0xFF333333),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$homeGoles - $awayGoles',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF667eea)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  m['teamAwayNombre'],
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: m['teamAwayNombre'] == teamName ? FontWeight.bold : FontWeight.normal,
                                    color: m['teamAwayNombre'] == teamName ? const Color(0xFF667eea) : const Color(0xFF333333),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
