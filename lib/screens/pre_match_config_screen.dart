import 'package:flutter/material.dart';
import '../api_service.dart';
import '../match_state.dart';
import 'match_setup_screen.dart';

class PreMatchConfigScreen extends StatefulWidget {
  const PreMatchConfigScreen({super.key});

  @override
  State<PreMatchConfigScreen> createState() => _PreMatchConfigScreenState();
}

enum RivalMode { free, system }

class _PreMatchConfigScreenState extends State<PreMatchConfigScreen> {
  RivalMode _rivalMode = RivalMode.free;
  int? _rivalTeamId;
  final _rivalNameController = TextEditingController();
  List<dynamic> _myTeams = [];
  bool _isLoadingTeams = true;

  @override
  void initState() {
    super.initState();
    _loadMyTeams();
  }

  @override
  void dispose() {
    _rivalNameController.dispose();
    super.dispose();
  }

  Future<void> _loadMyTeams() async {
    try {
      final teams = await apiService.getMyTeams();
      setState(() {
        _myTeams = teams;
        _isLoadingTeams = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTeams = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Configurar Partido', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Personaliza los detalles del encuentro antes de saltar al campo.',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader('¿Contra quién juegas?', Icons.sports_soccer),
                        const SizedBox(height: 16),
                        _buildModeSelector(),
                        const SizedBox(height: 24),
                        if (_rivalMode == RivalMode.free)
                          _buildFreeNameInput()
                        else
                          _buildSystemTeamSelector(),
                        const SizedBox(height: 40),
                        _buildContinueButton(),
                      ],
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF667eea), size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: SegmentedButton<RivalMode>(
        segments: const [
          ButtonSegment(
            value: RivalMode.free,
            label: Text('Nombre libre'),
            icon: Icon(Icons.edit, size: 18),
          ),
          ButtonSegment(
            value: RivalMode.system,
            label: Text('De mis equipos'),
            icon: Icon(Icons.list, size: 18),
          ),
        ],
        selected: {_rivalMode},
        onSelectionChanged: (Set<RivalMode> newSelection) {
          setState(() {
            _rivalMode = newSelection.first;
            _rivalTeamId = null;
          });
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) return const Color(0xFF667eea);
            return null;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return Colors.grey.shade700;
          }),
          side: WidgetStateProperty.all(BorderSide.none),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
    );
  }

  Widget _buildFreeNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Escribe el nombre del rival:', style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _rivalNameController,
          decoration: InputDecoration(
            hintText: 'Ej: Colegio San José',
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: const Icon(Icons.drive_file_rename_outline, color: Color(0xFF667eea)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF667eea), width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemTeamSelector() {
    if (_isLoadingTeams) return const Center(child: CircularProgressIndicator());
    if (_myTeams.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
        child: Text('No tienes otros equipos creados. Usa "Nombre libre".', style: TextStyle(color: Colors.amber.shade900)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selecciona uno de tus equipos:', style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: const Icon(Icons.shield, color: Color(0xFF667eea)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          value: _rivalTeamId,
          hint: const Text('Elige equipo...'),
          items: _myTeams.map<DropdownMenuItem<int>>((team) {
            return DropdownMenuItem<int>(
              value: team['id'],
              child: Text(team['nombre'] ?? 'Sin nombre'),
            );
          }).toList(),
          onChanged: (val) => setState(() => _rivalTeamId = val),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _handleContinue,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: const Color(0xFF667eea).withOpacity(0.4),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Configurar Alineación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Icon(Icons.arrow_forward),
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    final name = _rivalNameController.text.trim();
    if (_rivalMode == RivalMode.free && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe un nombre para el rival')));
      return;
    }
    if (_rivalMode == RivalMode.system && _rivalTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un equipo rival')));
      return;
    }

    // Mostrar loading si hay que crear/buscar rival externo
    if (_rivalMode == RivalMode.free) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
      
      // Encontrar el clubId del equipo actual
      int? currentClubId;
      for (var club in matchState.cachedClubs) {
        final clubId = club['id'] as int;
        final teams = matchState.cachedTeams[clubId] ?? [];
        if (teams.any((t) => t['id'] == matchState.currentTeamId)) {
          currentClubId = clubId;
          break;
        }
      }

      if (currentClubId != null) {
        final realRivalId = await matchState.ensureExternalRival(name, currentClubId);
        matchState.rivalTeamId = realRivalId;
      }
      
      if (mounted) Navigator.pop(context); // Quitar loading
      matchState.rivalName = name;
    } else {
      final team = _myTeams.firstWhere((t) => t['id'] == _rivalTeamId);
      matchState.rivalName = team['nombre'];
      matchState.rivalTeamId = _rivalTeamId;

      // También identificar al jugador fantasma para equipos del sistema
      try {
        final players = await apiService.getPlayers(_rivalTeamId!);
        final ghost = players.where((p) => p['nombre'] == 'EQUIPO' || p['dorsal'] == '0').firstOrNull;
        if (ghost != null) {
          matchState.rivalGhostPlayerId = int.tryParse(ghost['id'].toString());
        } else {
          // Si no existe, lo creamos para que los goles cuenten
          final newGhost = await apiService.createPlayer('EQUIPO', 0, _rivalTeamId!);
          matchState.rivalGhostPlayerId = newGhost?['id'] as int?;
        }
      } catch (e) {
        print("Error identificando rival ghost: $e");
      }
    }

    matchState.rivalPlayers = []; 
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MatchSetupScreen()),
      );
    }
  }
}
