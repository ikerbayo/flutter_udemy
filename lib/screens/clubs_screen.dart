import 'package:flutter/material.dart';
import '../api_service.dart';
import '../match_state.dart';
import 'teams_screen.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  List<dynamic> _clubs = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    setState(() => _isLoading = true);
    try {
      final clubs = await apiService.getClubs();
      setState(() {
        _clubs = clubs;
        _isLoading = false;
      });
      
      // Eager sync of all data in background
      _syncAllData();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _syncAllData() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await matchState.loadAllData();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mis Clubes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClubs,
          ),
        ],
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
                  'Bienvenido de nuevo. Gestiona tus clubes y equipos desde aquí.',
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
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF667eea)))
                    : _clubs.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _clubs.length,
                          itemBuilder: (context, index) {
                            final club = _clubs[index];
                            return _buildClubCard(club);
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

  Widget _buildClubCard(dynamic club) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TeamsScreen(club: club)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: club['logo'] != null
                    ? ClipOval(
                        child: Image.network(
                          club['logo'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.shield, color: Color(0xFF667eea), size: 30),
                        ),
                      )
                    : const Icon(Icons.shield, color: Color(0xFF667eea), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people_outline, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Gestionado por ti',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.business, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text(
          'No tienes clubes todavía',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const Text(
          'Añade un club desde la web para empezar.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
