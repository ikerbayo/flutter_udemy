import 'package:flutter/material.dart';
import '../api_service.dart';
import '../match_state.dart';
import 'standings_screen.dart';
import 'pre_match_config_screen.dart';
import 'manage_players_screen.dart';

class TeamsScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  final bool initialShowRivales;
  final Map<String, dynamic>? currentTeam;
  const TeamsScreen({super.key, required this.club, this.initialShowRivales = false, this.currentTeam});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  List<dynamic> _teams = [];
  bool _isLoading = true;
  late bool _showRivales;

  bool get _isIsolatedRivalsMode => widget.currentTeam != null && _showRivales;

  @override
  void initState() {
    super.initState();
    _showRivales = widget.initialShowRivales;
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = widget.currentTeam != null && widget.initialShowRivales
          ? await apiService.getRivalesByTeam(widget.currentTeam!['id'])
          : await apiService.getTeamsByClub(widget.club['id']);
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

  Widget build(BuildContext context) {
    final filteredTeams = _teams.where((t) {
      if (widget.currentTeam != null && widget.initialShowRivales) return true;
      bool isExterno = t['categoriaFutbol'] == 'Externo';
      return _showRivales ? isExterno : !isExterno;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.currentTeam != null ? 'Rivales: ${widget.currentTeam!['nombre']}' : widget.club['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
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
      floatingActionButton: _isIsolatedRivalsMode ? null : FloatingActionButton(
        onPressed: () => _showCreateTeamModal(context),
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateTeamModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: _showRivales ? 'Externo' : '');
    final logoCtrl = TextEditingController();
    bool isSubmitting = false;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _showRivales ? 'Añadir Nuevo Rival' : 'Añadir Nuevo Equipo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Equipo',
                        prefixIcon: const Icon(Icons.group, color: Color(0xFF667eea)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: categoryCtrl,
                      decoration: InputDecoration(
                        labelText: 'Categoría (ej. Fútbol 7)',
                        prefixIcon: const Icon(Icons.category, color: Color(0xFF667eea)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: logoCtrl,
                      decoration: InputDecoration(
                        labelText: 'URL del Escudo (Opcional)',
                        prefixIcon: const Icon(Icons.image, color: Color(0xFF667eea)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                        ),
                      ),
                    ),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMsg!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
                      )
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final nombre = nameCtrl.text.trim();
                              final categoria = categoryCtrl.text.trim();
                              if (nombre.isEmpty) {
                                setModalState(() => errorMsg = "El nombre es obligatorio");
                                return;
                              }
                              setModalState(() {
                                isSubmitting = true;
                                errorMsg = null;
                              });

                              try {
                                await apiService.createTeam(
                                  nombre, 
                                  categoria.isEmpty ? 'Fútbol 11' : categoria, 
                                  widget.club['id'], 
                                  logoCtrl.text.trim(),
                                  parentTeamId: widget.currentTeam != null ? widget.currentTeam!['id'] : null,
                                );
                                if (modalContext.mounted) {
                                  Navigator.pop(modalContext);
                                }
                                _loadTeams();
                                if (mounted) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Equipo guardado correctamente.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() {
                                  isSubmitting = false;
                                  errorMsg = "Error: ${e.toString()}";
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
          if (!_showRivales) ...[
            const SizedBox(height: 8),
            const Text(
              'Haz clic en el botón "+" para crear uno.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
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
      child: Stack(
        children: [
          Padding(
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
                if (!_isIsolatedRivalsMode) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTeamActionButton(
                        icon: Icons.play_arrow,
                        label: 'Jugar',
                        color: Colors.green.shade700,
                        onTap: () async {
                          await matchState.selectTeam(team['id']);
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PreMatchConfigScreen()),
                            );
                          }
                        },
                      ),
                      _buildTeamActionButton(
                        icon: Icons.person_search,
                        label: 'Plantilla',
                        color: const Color(0xFF667eea),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ManagePlayersScreen(team: team)),
                          );
                        },
                      ),
                      _buildTeamActionButton(
                        icon: Icons.table_chart_outlined,
                        label: 'Tabla',
                        color: Colors.orange.shade700,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => StandingsScreen(club: widget.club, currentTeam: team)),
                          );
                        },
                      ),
                      _buildTeamActionButton(
                        icon: Icons.sports_soccer,
                        label: 'Rivales',
                        color: Colors.redAccent.shade700,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TeamsScreen(club: widget.club, initialShowRivales: true, currentTeam: team)),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              tooltip: 'Eliminar Equipo',
              onPressed: () => _showDeleteConfirmation(team),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
