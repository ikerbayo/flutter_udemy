import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api'; // Or your actual API URL

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Map<String, String> _headers(String? token) {
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }

  // 1. Auth
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers(null),
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['token'] != null) {
          await saveToken(json['token']);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<String?> register(String nombre, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers(null),
        body: jsonEncode({'nombre': nombre, 'email': email, 'password': password}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // Null means success
      } else {
        return 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      print('Register error: $e');
      return 'Connection error: $e';
    }
  }

  // 2. Clubs
  Future<List<dynamic>> getClubs() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/clubs'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener clubes: ${response.statusCode}');
      }
    } catch (e) {
      print('Get clubs error: $e');
      rethrow;
    }
  }

  Future<dynamic> createClub(String nombre, String logo) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/clubs'),
        headers: _headers(token),
        body: jsonEncode({
          'nombre': nombre,
          'logo': logo,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.trim().isEmpty) return true;
        return jsonDecode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Create club error: $e');
      rethrow;
    }
  }

  // 3. Teams
  Future<List<dynamic>> getMyTeams() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/teams/my-teams'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener equipos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Get my teams error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getTeamsByClub(int clubId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/teams/club/$clubId'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener equipos de club: ${response.statusCode}');
      }
    } catch (e) {
      print('Get teams by club error: $e');
      rethrow;
    }
  }

  Future<dynamic> createTeam(String nombre, String categoriaFutbol, int clubId, String escudoUrl) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/teams'),
        headers: _headers(token),
        body: jsonEncode({
          'nombre': nombre,
          'categoriaFutbol': categoriaFutbol,
          'clubId': clubId,
          'escudoUrl': escudoUrl,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.trim().isEmpty) {
          return true; // Success but no body
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Create team error: $e');
      rethrow;
    }
  }

  Future<void> deleteTeam(int teamId) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/teams/$teamId'),
        headers: _headers(token),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar equipo: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete team error: $e');
      rethrow;
    }
  }

  // 4. Players
  Future<List<dynamic>> getPlayers(int teamId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/players/team/$teamId'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener jugadores: ${response.statusCode}');
      }
    } catch (e) {
      print('Get players error: $e');
      rethrow;
    }
  }

  Future<dynamic> createPlayer(String nombre, int dorsal, int teamId) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/players'),
      headers: _headers(token),
      body: jsonEncode({
        'nombre': nombre,
        'dorsal': dorsal,
        'posicion': 'Desconocida',
        'foto': '',
        'teamId': teamId,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // 5. Matches
  Future<int?> createMatch(int teamHomeId, {int? teamAwayId, String? rivalNombre, required String fecha}) async {
    final token = await getToken();
    final body = <String, dynamic>{
      'teamHomeId': teamHomeId,
      'fecha': fecha,
    };
    if (teamAwayId != null) {
      body['teamAwayId'] = teamAwayId;
    } else if (rivalNombre != null && rivalNombre.isNotEmpty) {
      body['rivalNombre'] = rivalNombre;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/matches'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['id'] as int?;
    }
    return null;
  }

  // 6. Events
  Future<bool> syncEvents(List<Map<String, dynamic>> events) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/events/sync'),
        headers: _headers(token),
        body: jsonEncode({'events': events}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 7. Standings
  Future<List<dynamic>> getStandingsByClub(int clubId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/standings/club/$clubId'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener clasificación: ${response.statusCode}');
      }
    } catch (e) {
      print('Get standings error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getMatchHistory(int teamId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/standings/team/$teamId/history'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener historial: ${response.statusCode}');
      }
    } catch (e) {
      print('Get history error: $e');
      rethrow;
    }
  }

  Future<void> updateMatchStatus(int matchId, String status) async {
    try {
      final token = await getToken();
      await http.patch(
        Uri.parse('$baseUrl/matches/$matchId/status?estado=$status'),
        headers: _headers(token),
      );
    } catch (e) {
      // Silence
    }
  }

  Future<List<dynamic>> getMatches() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/matches'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getEventsByMatchId(int matchId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/events/$matchId'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

final apiService = ApiService();
