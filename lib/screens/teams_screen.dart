import 'package:flutter/material.dart';
import '../api_service.dart';
import '../match_state.dart';
import 'standings_screen.dart';
import 'pre_match_config_screen.dart';
import 'manage_players_screen.dart';

class TeamsScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  const TeamsScreen({super.key, required this.club});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  List<dynamic> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await apiService.getTeamsByClub(widget.club['id']);
      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  bool _showRivales = false;

  @override
  Widget build(BuildContext context) {
    final filteredTeams = _teams.where((t) {
      bool isExterno = t['categoriaFutbol'] == 'Externo';
      return _showRivales ? isExterno : !isExterno;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.club['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
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
              _buildHeaderActions(),
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
                    : filteredTeams.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: filteredTeams.length,
                          itemBuilder: (context, index) {
                            final team = filteredTeams[index];
                            return _buildTeamCard(team);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_showRivales ? Icons.sports_soccer : Icons.group_off, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            _showRivales ? 'No hay rivales registrados todavía' : 'No tienes equipos en este club',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuickAction(
            icon: Icons.table_chart_outlined,
            label: 'Tabla',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StandingsScreen(club: widget.club)),
              );
            },
          ),
          _buildQuickAction(
            icon: _showRivales ? Icons.group : Icons.sports_soccer,
            label: _showRivales ? 'Mis Equipos' : 'Rivales',
            onTap: () => setState(() => _showRivales = !_showRivales),
          ),
          _buildQuickAction(
            icon: Icons.play_circle_fill,
            label: 'Jugar',
            isPrimary: true,
            onTap: () async {
              if (_teams.isNotEmpty) {
                final myTeams = _teams.where((t) => t['categoriaFutbol'] != 'Externo').toList();
                if (myTeams.isNotEmpty) {
                  await matchState.selectTeam(myTeams.first['id']);
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PreMatchConfigScreen()),
                    );
                  }
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crea un equipo primero.')));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isPrimary ? const Color(0xFF667eea) : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? const Color(0xFF667eea) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(dynamic team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.group, color: Color(0xFF667eea)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Text(
                        team['categoriaFutbol'] ?? 'Categoría libre',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      await matchState.selectTeam(team['id']);
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PreMatchConfigScreen()),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Jugar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.grey.shade300),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ManagePlayersScreen(team: team)),
                      );
                    },
                    icon: const Icon(Icons.person_search, size: 18),
                    label: const Text('Plantilla'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF667eea),
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.grey.shade300),
                Expanded(
                  child: IconButton(
                    onPressed: () => _showDeleteConfirmation(team),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    tooltip: 'Eliminar Equipo',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(dynamic team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar equipo?'),
        content: Text('Esta acción eliminará "${team['nombre']}" y todos sus datos de forma permanente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTeam(team['id']);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeam(int teamId) async {
    try {
      setState(() => _isLoading = true);
      await apiService.deleteTeam(teamId);
      await _loadTeams();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipo eliminado correctamente.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }
}
