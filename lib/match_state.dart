import 'dart:async';
import 'package:flutter/material.dart';
import 'player.dart';
import 'api_service.dart';

class MatchState extends ChangeNotifier {
  List<Player> players = [];

  // Nombres técnicos del backend (MatchEventService.java)
  final List<String> statCategories = [
    'Gol',
    'Asistencia',
    'Tiro_Puerta',
    'Falta_Cometida',
    'Amarilla',
    'Roja',
  ];

  // Etiquetas amigables para la UI
  final Map<String, String> statLabels = {
    'Gol': '⚽ GOL',
    'Asistencia': '👟 ASIST.',
    'Tiro_Puerta': '🎯 TIRO PK',
    'Falta_Cometida': '🛑 FALTA',
    'Amarilla': '🟨 AMARILLA',
    'Roja': '🟥 ROJA',
  };

  // --- CACHÉ GLOBAL (cargada al hacer login) ---
  List<dynamic> cachedClubs = [];
  /// clubId → lista de equipos
  Map<int, List<dynamic>> cachedTeams = {};
  /// teamId → lista de jugadores (raw JSON)
  Map<int, List<dynamic>> cachedPlayers = {};

  bool isLoadingData = false;

  /// Descarga todos los datos del usuario de una vez.
  /// Llama a esto justo después del login.
  Future<void> loadAllData() async {
    isLoadingData = true;
    notifyListeners();
    try {
      cachedClubs = await apiService.getClubs();

      // Para cada club, descarga sus equipos
      for (final club in cachedClubs) {
        final clubId = club['id'] as int;
        final teams = await apiService.getTeamsByClub(clubId);
        cachedTeams[clubId] = teams;

        // Para cada equipo, descarga sus jugadores
        for (final team in teams) {
          final teamId = team['id'] as int;
          try {
            final rawPlayers = await apiService.getPlayers(teamId);
            cachedPlayers[teamId] = rawPlayers;
          } catch (_) {
            cachedPlayers[teamId] = [];
          }
        }
      }
    } catch (e) {
      // Fallo silencioso — la app funciona igual, solo sin prefetch
    } finally {
      isLoadingData = false;
      notifyListeners();
    }
  }

  /// Activa un equipo: carga sus jugadores desde el caché (o la API si no están).
  Future<void> selectTeam(int teamId) async {
    currentTeamId = teamId;
    List<dynamic> rawPlayers = cachedPlayers[teamId] ?? [];
    if (rawPlayers.isEmpty) {
      // Fallback: pedir a la API si no estaba en caché
      try {
        rawPlayers = await apiService.getPlayers(teamId);
        cachedPlayers[teamId] = rawPlayers;
      } catch (_) {}
    }
    await loadPlayersFromApi(rawPlayers, teamId);
  }

  int? currentTeamId;
  int? currentMatchId;

  // --- SCOREBOARD & TIMER ---
  int homeScore = 0;
  int awayScore = 0;
  int msElapsed = 0;
  bool isTimerRunning = false;
  Timer? _timer;

  String get formattedTime {
    int totalSecs = msElapsed ~/ 1000;
    int minutes = totalSecs ~/ 60;
    int seconds = totalSecs % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get millisecondsText {
    int ms = (msElapsed % 1000) ~/ 100; // Solo un decimal
    return '.$ms';
  }

  void startTimer() {
    if (!isTimerRunning) {
      isTimerRunning = true;
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        msElapsed += 100;
        notifyListeners();
      });
      notifyListeners();
    }
  }

  void pauseTimer() {
    isTimerRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    pauseTimer();
    msElapsed = 0;
    notifyListeners();
  }

  void adjustTime(int deltaSeconds) {
    msElapsed += deltaSeconds * 1000;
    if (msElapsed < 0) msElapsed = 0;
    notifyListeners();
  }

  void updateScoreLocalRival(bool forUserTeam, bool increment) {
    // Si forUserTeam es true, incrementamos el marcador del equipo del usuario (local o visitante)
    // Si forUserTeam es false, es un gol del rival
    bool isHome = forUserTeam ? isLocal : !isLocal;
    
    if (isHome) {
      homeScore = increment ? homeScore + 1 : (homeScore > 0 ? homeScore - 1 : 0);
    } else {
      awayScore = increment ? awayScore + 1 : (awayScore > 0 ? awayScore - 1 : 0);
    }
    notifyListeners();
  }

  void recordRivalGoal(bool increment) {
    updateScoreLocalRival(false, increment);
    
    if (increment) {
      _recordRivalEvent('Gol', 1);
    } else {
      _removeLastRivalEvent('Gol');
    }
  }

  void _recordRivalEvent(String type, int val) {
    if (currentMatchId != null) {
      // Prioridad: 
      // 1. Primer jugador de la lista rival (si hay alineación cargada)
      // 2. El "Jugador Fantasma" del rival (para goles anónimos del sistema/externos)
      // 3. Fallback a 0
      dynamic rivalId = 0;
      if (rivalPlayers.isNotEmpty) {
        rivalId = rivalPlayers.first['id'] ?? 0;
      } else if (rivalGhostPlayerId != null) {
        rivalId = rivalGhostPlayerId;
      }

      recordedEvents.add({
        "matchId": currentMatchId,
        "playerId": rivalId is int ? rivalId : int.tryParse(rivalId.toString()) ?? 0,
        "tipo": type,
        "minuto": msElapsed ~/ 60000,
        "valor": val,
      });
    }
  }

  void _removeLastRivalEvent(String type) {
    if (currentMatchId != null && rivalPlayers.isNotEmpty) {
      final firstRivalId = rivalPlayers.first['id'].toString();
      int indexToRemove = recordedEvents.lastIndexWhere((e) => 
        e["playerId"].toString() == firstRivalId && 
        e["tipo"] == type
      );
      if (indexToRemove != -1) {
        recordedEvents.removeAt(indexToRemove);
      }
    }
  }
  // ↑ End of rival goal helpers — do NOT duplicate below

  Future<void> fetchAndAggregateStats(int teamId) async {
    try {
      final allMatches = await apiService.getMatches();
      final relevantMatches = allMatches.where((m) => 
        (m['teamHomeId'].toString() == teamId.toString() || 
         m['teamAwayId'].toString() == teamId.toString()) && 
         m['estado'] == 'Finalizado'
      ).toList();

      // Clear existing stats
      for (var p in players) {
        p.matchesPlayed = 0;
        for (var cat in statCategories) {
          p.stats[cat] = 0;
        }
      }

      // Fetch all events concurrently
      final allEventsNested = await Future.wait(
        relevantMatches.map((m) => apiService.getEventsByMatchId(m['id']))
      );

      for (var events in allEventsNested) {
        final playersInThisMatch = <String>{};

        for (var e in events) {
          final playerId = e['playerId']?.toString();
          if (playerId == null) continue;
          
          final player = players.where((p) => p.id == playerId).firstOrNull;
          if (player == null) continue;

          final tipo = e['tipo'] as String;
          if (player.stats.containsKey(tipo)) {
            player.stats[tipo] = (player.stats[tipo] ?? 0) + 1;
          }
          playersInThisMatch.add(playerId);
        }

        for (var pid in playersInThisMatch) {
          final p = players.where((p) => p.id == pid).firstOrNull;
          if (p != null) p.matchesPlayed++;
        }
      }
      notifyListeners();
    } catch (e) {
      // Fail silently or log
    }
  }

  int? teamGhostPlayerId;
  int? rivalGhostPlayerId;

  Future<void> loadPlayersFromApi(List<dynamic> playersData, int teamId) async {
    currentTeamId = teamId;
    players = playersData.map((json) {
      return Player(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: json['nombre'] ?? 'Jugador',
        dorsal: json['dorsal']?.toString() ?? '0',
        foto: json['foto'],
        posicionPrincipal: json['posicionPrincipal'],
        stats: {for (var cat in statCategories) cat: 0},
      );
    }).toList();
    
    // Buscar o identificar al "Jugador Fantasma" para goles de equipo
    final ghost = players.where((p) => p.name.toUpperCase() == 'EQUIPO' || p.dorsal == '0').firstOrNull;
    if (ghost != null) {
      teamGhostPlayerId = int.tryParse(ghost.id);
    } else {
      teamGhostPlayerId = null;
      // Lo crearemos bajo demanda
      await _ensureGhostPlayer(teamId);
    }

    await fetchAndAggregateStats(teamId);
    notifyListeners();
  }

  Future<void> _ensureGhostPlayer(int teamId) async {
    try {
      final result = await apiService.createPlayer('EQUIPO', 0, 'Desconocida', '', teamId);
      if (result != null && result['id'] != null) {
        teamGhostPlayerId = result['id'] as int;
      }
    } catch (e) {
      // Fail silently
    }
  }

  /// Asegura que un rival con nombre libre tenga una entidad real en la DB para que sus goles cuenten
  Future<int?> ensureExternalRival(String name, int clubId) async {
    try {
      // 1. Buscar si el equipo ya existe en los rivales de este equipo
      final teams = currentTeamId != null 
          ? await apiService.getRivalesByTeam(currentTeamId!)
          : await apiService.getTeamsByClub(clubId);
      
      var rivalTeam = teams.where((t) => t['nombre'] == name).firstOrNull;

      if (rivalTeam == null) {
        // Asociar como rival del equipo actual si existe el scope
        rivalTeam = await apiService.createTeam(
          name, 
          'Externo', 
          clubId, 
          'https://via.placeholder.com/150',
          parentTeamId: currentTeamId
        );
      }

      final rivalId = rivalTeam['id'] as int;

      // 2. Asegurar que ese equipo tenga su propio "EQUIPO" player para los goles
      final rivalPlayersData = await apiService.getPlayers(rivalId);
      var ghost = rivalPlayersData.where((p) => p['nombre'] == 'EQUIPO' || p['dorsal'] == '0').firstOrNull;
      if (ghost == null) {
        final newGhost = await apiService.createPlayer('EQUIPO', 0, 'Desconocida', '', rivalId);
        rivalGhostPlayerId = newGhost?['id'] as int?;
      } else {
        rivalGhostPlayerId = int.tryParse(ghost['id'].toString());
      }

      return rivalId;
    } catch (e) {
      print("Error crítico en ensureExternalRival: $e");
      return null;
    }
  }

  void loadDefaultPlayers() {
    players.clear();
    notifyListeners();
  }

  // Jugadores elegidos para el partido actual
  List<Player> currentMatchPlayers = [];

  // JUGADOR SELECCIONADO (Asegúrate de que se llame así para que LiveMatch lo lea bien)
  Player? selectedPlayer;

  // Asignaciones de posición en el campo visual (índice de slot -> Player)
  Map<int, Player> positionAssignments = {};

  // Estadísticas temporales del partido en curso
  Map<String, Map<String, int>> sessionStats = {};

  // Lista de eventos para sync con la API
  List<Map<String, dynamic>> recordedEvents = [];

  // Lógica de tácticas
  String matchType = 'Fútbol 11 (Infantil+)';
  String matchFormation = '1-4-4-2';

  // Configuración de Partido
  bool isLocal = true;
  String rivalName = '';
  int? rivalTeamId;
  List<dynamic> rivalPlayers = [];

  /// Alias for [rivalName] used by the live match screen.
  String get rivalTeamName => rivalName;

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
    positionAssignments.clear(); // Limpiar el campo al cambiar de tipo
    notifyListeners();
  }

  void changeFormation(String formation) {
    matchFormation = formation;
    positionAssignments.clear(); // Limpiar el campo al cambiar formación
    notifyListeners();
  }

  void setMatchConfig(bool local, String rival) {
    isLocal = local;
    rivalName = rival;
    notifyListeners();
  }

  void togglePlayerInMatch(Player player) {
    if (currentMatchPlayers.contains(player)) {
      currentMatchPlayers.remove(player);
      // Remove from visual field if assigned
      positionAssignments.removeWhere((key, value) => value.id == player.id);
    } else {
      currentMatchPlayers.add(player);
    }
    notifyListeners();
  }

  void assignPlayerToPosition(int positionIndex, Player player) {
    // Si el jugador ya está en otra posición, lo quitamos de ahí
    positionAssignments.removeWhere((key, value) => value.id == player.id);
    positionAssignments[positionIndex] = player;
    // Asegurarse de que esté en currentMatchPlayers
    if (!currentMatchPlayers.contains(player)) {
      currentMatchPlayers.add(player);
    }
    notifyListeners();
  }

  void removePlayerFromPosition(int positionIndex) {
    if (positionAssignments.containsKey(positionIndex)) {
      Player playerToRemove = positionAssignments[positionIndex]!;
      positionAssignments.remove(positionIndex);
      // Opcional: ¿Quitarlo también de currentMatchPlayers si no está en el campo?
      // Por ahora lo dejamos en la lista de currentMatchPlayers como "banquillo"
      currentMatchPlayers.remove(playerToRemove);
    }
    notifyListeners();
  }

  // --- MÉTODOS DE PARTIDO ---

  void startNewMatch() {
    sessionStats.clear();
    recordedEvents.clear();
    homeScore = 0;
    awayScore = 0;
    msElapsed = 0;
    isTimerRunning = false;
    _timer?.cancel();

    // Use the assigned players on the field initially
    currentMatchPlayers = positionAssignments.values.toList();
    for (var p in currentMatchPlayers) {
      p.matchesPlayed++; // Sumar partido al historial global (localmente)
      sessionStats[p.id] = {for (var cat in statCategories) cat: 0};

      // Registrar participación en el API (via sync mas tarde)
      if (currentMatchId != null) {
        recordedEvents.add({
          "matchId": currentMatchId,
          "playerId": int.tryParse(p.id) ?? 0,
          "tipo": "Inicio_Partido",
          "minuto": 0,
          "valor": 1,
        });
      }
    }
    notifyListeners();
  }

  // IMPORTANTE: Este método es el que usa el "onTap" del selector de jugadores en Live
  void selectPlayer(Player player) {
    selectedPlayer = player;
    notifyListeners();
  }

  void recordUserGoal(bool increment, {Player? player}) {
    updateScoreLocalRival(true, increment);
    
    if (currentMatchId != null) {
      if (increment) {
        // Si 'player' es null, es un gol de equipo (manual).
        // Usamos el ID del "Jugador Fantasma" (o 0 si falla) para que la API lo cuente en la clasificación.
        final pid = player != null ? (int.tryParse(player.id) ?? 0) : (teamGhostPlayerId ?? 0);
        
        if (player != null) {
          player.stats['Gol'] = (player.stats['Gol'] ?? 0) + 1;
          sessionStats[player.id]?['Gol'] = (sessionStats[player.id]?['Gol'] ?? 0) + 1;
        }

        recordedEvents.add({
          "matchId": currentMatchId,
          "playerId": pid,
          "tipo": "Gol",
          "minuto": msElapsed ~/ 60000,
          "valor": 1,
        });
      } else {
        // Al restar, intentamos quitar el del jugador específico o el último gol genérico
        int indexToRemove = recordedEvents.lastIndexWhere((e) => 
          e["matchId"] == currentMatchId && 
          e["tipo"] == "Gol" &&
          (player == null ? (e["playerId"] == 0 || e["playerId"] == teamGhostPlayerId) : e["playerId"] == (int.tryParse(player.id) ?? 0))
        );

        // FALLBACK: Si es una resta general (player == null) y no encontramos goles anónimos, 
        // buscamos el ÚLTIMO gol de cualquier jugador para mantener la coherencia del marcador.
        if (player == null && indexToRemove == -1) {
          indexToRemove = recordedEvents.lastIndexWhere((e) => 
            e["matchId"] == currentMatchId && e["tipo"] == "Gol"
          );
        }

        if (indexToRemove != -1) {
          final removedPid = recordedEvents[indexToRemove]['playerId'];
          if (removedPid != 0 && removedPid != teamGhostPlayerId) {
            // Si quitamos uno de un jugador real, actualizar sus stats locales
            final p = players.where((p) => p.id == removedPid.toString()).firstOrNull;
            if (p != null) {
              p.stats['Gol'] = (p.stats['Gol'] ?? 1) - 1;
              sessionStats[p.id]?['Gol'] = (sessionStats[p.id]?['Gol'] ?? 1) - 1;
            }
          }
          recordedEvents.removeAt(indexToRemove);
        }
      }
    }
    notifyListeners();
  }



  void incrementStat(String statName) {
    if (selectedPlayer != null) {
      // Si es un gol, usamos el método especializado
      if (statName.toLowerCase() == 'gol') {
        recordUserGoal(true, player: selectedPlayer);
        return;
      }

      // Para el resto de estadísticas
      selectedPlayer!.stats[statName] = (selectedPlayer!.stats[statName] ?? 0) + 1;
      sessionStats[selectedPlayer!.id]![statName] = (sessionStats[selectedPlayer!.id]![statName] ?? 0) + 1;

      if (currentMatchId != null) {
        recordedEvents.add({
          "matchId": currentMatchId,
          "playerId": int.tryParse(selectedPlayer!.id) ?? 0,
          "tipo": statName,
          "minuto": msElapsed ~/ 60000,
          "valor": 1,
        });
      }
      notifyListeners();
    }
  }

  void decrementStat(String statName) {
    if (selectedPlayer != null) {
      if (statName.toLowerCase() == 'gol') {
        recordUserGoal(false, player: selectedPlayer);
        return;
      }

      int currentVal = sessionStats[selectedPlayer!.id]![statName] ?? 0;
      if (currentVal > 0) {
        selectedPlayer!.stats[statName] = (selectedPlayer!.stats[statName] ?? 0) - 1;
        sessionStats[selectedPlayer!.id]![statName] = currentVal - 1;

        if (currentMatchId != null) {
          int indexToRemove = recordedEvents.lastIndexWhere(
            (e) =>
                e["matchId"] == currentMatchId &&
                e["playerId"] == (int.tryParse(selectedPlayer!.id) ?? 0) &&
                e["tipo"] == statName,
          );
          if (indexToRemove != -1) {
            recordedEvents.removeAt(indexToRemove);
          }
        }
        notifyListeners();
      }
    }
  }

  // --- GESTIÓN DE PLANTILLA (SIN QUITAR NADA) ---

  Future<void> addPlayer(String name, String dorsal) async {
    if (currentTeamId != null) {
      final json = await apiService.createPlayer(
        name,
        int.tryParse(dorsal) ?? 0,
        'Desconocida',
        '',
        currentTeamId!,
      );
      if (json != null) {
        final newPlayer = Player(
          id:
              json['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: json['nombre'] ?? name,
          dorsal: json['dorsal']?.toString() ?? dorsal,
          stats: {for (var cat in statCategories) cat: 0},
        );
        players.add(newPlayer);
        notifyListeners();
      }
    } else {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final matchState = MatchState();
