class Player {
  final String id;
  final String name;
  final String dorsal;
  int matchesPlayed;
  Map<String, int> stats;

  Player({
    required this.id,
    required this.name,
    required this.dorsal,
    this.matchesPlayed = 0,
    required this.stats,
  });
}