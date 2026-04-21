class Player {
  final String id;
  final String name;
  final String dorsal;
  final String? foto;
  final String? posicionPrincipal;
  int matchesPlayed;
  Map<String, int> stats;

  Player({
    required this.id,
    required this.name,
    required this.dorsal,
    this.foto,
    this.posicionPrincipal,
    this.matchesPlayed = 0,
    required this.stats,
  });

  // Helper to get goals quickly
  int get goals => stats['Gol'] ?? 0;
}