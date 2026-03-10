import 'package:flutter/material.dart';
import 'player.dart';

class MatchState extends ChangeNotifier {
  List<Player> players = [];
  List<String> statCategories = ['Goles', 'Tiros a puerta', 'Faltas', 'Asistencias'];

  MatchState() {
    loadDefaultPlayers();
  }

  void loadDefaultPlayers() {
    players.clear();
    final defaultPlayers = [
      {'name': 'Casillas', 'dorsal': '1'},
      {'name': 'Piqué', 'dorsal': '3'},
      {'name': 'Puyol', 'dorsal': '5'},
      {'name': 'Iniesta', 'dorsal': '6'},
      {'name': 'Villa', 'dorsal': '7'},
      {'name': 'Xavi', 'dorsal': '8'},
      {'name': 'F. Torres', 'dorsal': '9'},
      {'name': 'Cesc', 'dorsal': '10'},
      {'name': 'Capdevila', 'dorsal': '11'},
      {'name': 'X. Alonso', 'dorsal': '14'},
      {'name': 'Ramos', 'dorsal': '15'},
      {'name': 'Busquets', 'dorsal': '16'},
    ];

    for (var p in defaultPlayers) {
      players.add(Player(
        id: 'default_${p['dorsal']}',
        name: p['name']!,
        dorsal: p['dorsal']!,
        stats: {for (var cat in statCategories) cat: 0},
      ));
    }
    notifyListeners();
  }

  // Jugadores elegidos para el partido actual
  List<Player> currentMatchPlayers = []; 
  
  // JUGADOR SELECCIONADO (Asegúrate de que se llame así para que LiveMatch lo lea bien)
  Player? selectedPlayer;

  // Estadísticas temporales del partido en curso
  Map<String, Map<String, int>> sessionStats = {};

  // Lógica de tácticas
  String matchType = 'Fútbol 11 (Infantil+)'; 
  String matchFormation = '1-4-4-2'; 

  final Map<String, List<String>> availableFormations = {
    'Fútbol 5 (Prebenj/Benj)': ['1-2-2', '1-3-1', '1-1-2-1'],
    'Fútbol 7 (Benj/Alevín)': ['1-3-2-1', '1-2-3-1', '1-3-1-2'],
    'Fútbol 8 (Variante)': ['1-3-3-1', '1-2-3-2', '1-2-4-1'],
    'Fútbol 11 (Infantil+)': ['1-4-4-2', '1-4-3-3', '1-4-2-3-1', '1-3-5-2'],
  };

  // --- MÉTODOS DE CONFIGURACIÓN ---

  void changeMatchType(String type) {
    matchType = type;
    matchFormation = availableFormations[type]!.first;
    notifyListeners();
  }

  void changeFormation(String formation) {
    matchFormation = formation;
    notifyListeners();
  }

  void togglePlayerInMatch(Player player) {
    if (currentMatchPlayers.contains(player)) {
      currentMatchPlayers.remove(player);
    } else {
      currentMatchPlayers.add(player);
    }
    notifyListeners();
  }

  // --- MÉTODOS DE PARTIDO ---

  void startNewMatch() {
    sessionStats.clear();
    for (var p in currentMatchPlayers) {
      p.matchesPlayed++; // Sumar partido al historial global
      sessionStats[p.id] = {for (var cat in statCategories) cat: 0};
    }
    notifyListeners();
  }

  // IMPORTANTE: Este método es el que usa el "onTap" del selector de jugadores en Live
  void selectPlayer(Player player) {
    selectedPlayer = player;
    notifyListeners();
  }

  void incrementStat(String statName) {
    if (selectedPlayer != null) {
      // Sumar al total de la vida del jugador
      selectedPlayer!.stats[statName] = (selectedPlayer!.stats[statName] ?? 0) + 1;
      // Sumar solo a este partido
      sessionStats[selectedPlayer!.id]![statName] = (sessionStats[selectedPlayer!.id]![statName] ?? 0) + 1;
      notifyListeners();
    }
  }

  void decrementStat(String statName) {
    if (selectedPlayer != null) {
      int currentVal = sessionStats[selectedPlayer!.id]![statName] ?? 0;
      if (currentVal > 0) {
        selectedPlayer!.stats[statName] = (selectedPlayer!.stats[statName] ?? 0) - 1;
        sessionStats[selectedPlayer!.id]![statName] = currentVal - 1;
        notifyListeners();
      }
    }
  }

  // --- GESTIÓN DE PLANTILLA (SIN QUITAR NADA) ---

  void addPlayer(String name, String dorsal) {
    final newPlayer = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      dorsal: dorsal,
      stats: {for (var cat in statCategories) cat: 0},
    );
    players.add(newPlayer);
    notifyListeners();
  }

}

final matchState = MatchState();