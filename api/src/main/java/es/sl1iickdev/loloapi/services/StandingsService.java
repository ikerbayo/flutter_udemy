package es.sl1iickdev.loloapi.services;

import es.sl1iickdev.loloapi.dtos.GoalAggregationProjection;
import es.sl1iickdev.loloapi.dtos.MatchHistoryDTO;
import es.sl1iickdev.loloapi.dtos.StandingsDTO;
import es.sl1iickdev.loloapi.models.EventType;
import es.sl1iickdev.loloapi.models.Match;
import es.sl1iickdev.loloapi.models.Team;
import es.sl1iickdev.loloapi.models.User;
import es.sl1iickdev.loloapi.repositories.ClubRepository;
import es.sl1iickdev.loloapi.repositories.MatchEventRepository;
import es.sl1iickdev.loloapi.repositories.MatchRepository;
import es.sl1iickdev.loloapi.repositories.TeamRepository;
import es.sl1iickdev.loloapi.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StandingsService {

    private final TeamRepository teamRepository;
    private final MatchRepository matchRepository;
    private final MatchEventRepository matchEventRepository;
    private final ClubRepository clubRepository;

    public List<StandingsDTO> getMyStandings() {
        User user = SecurityUtils.getCurrentUser();
        var miClub = clubRepository.findFirstByPropietarioId(user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No tienes ningún Club asignado."));
        return calculateStandings(miClub.getId());
    }

    public List<StandingsDTO> getStandingsByClub(Long clubId) {
        User user = SecurityUtils.getCurrentUser();
        clubRepository.findByIdAndPropietarioId(clubId, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este club"));
        return calculateStandings(clubId);
    }

    public List<MatchHistoryDTO> getMatchHistory(Long teamId) {
        User user = SecurityUtils.getCurrentUser();
        teamRepository.findByIdAndClubPropietarioId(teamId, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este equipo"));

        List<Match> matches = matchRepository.findUltimosPartidosFinalizados(teamId, PageRequest.of(0, 5));
        if (matches.isEmpty()) return Collections.emptyList();

        List<Long> matchIds = matches.stream().map(Match::getId).collect(Collectors.toList());
        Map<Long, Map<Long, Integer>> goalsMap = buildGoalsMap(matchIds);

        return matches.stream()
                .map(m -> convertToHistoryDTO(m, goalsMap))
                .collect(Collectors.toList());
    }

    // ==============================
    // PRIVATE: Optimized Standings Calculation (2 queries instead of N*M)
    // ==============================

    private List<StandingsDTO> calculateStandings(Long clubId) {
        // 1. Get all teams for this club
        List<Team> teams = teamRepository.findByClubId(clubId);
        Map<Long, StandingsDTO> table = new HashMap<>();
        for (Team t : teams) {
            StandingsDTO s = new StandingsDTO();
            s.setTeamId(t.getId());
            s.setTeamNombre(t.getNombre());
            s.setEscudoUrl(t.getClub() != null ? t.getClub().getLogo() : null);
            s.setLastResults(new ArrayList<>());
            table.put(t.getId(), s);
        }

        // 2. ONE query: all finished matches for this club
        List<Match> matches = matchRepository.findFinishedMatchesByClubId(clubId);
        if (matches.isEmpty()) {
            return new ArrayList<>(table.values());
        }

        // 3. ONE query: aggregated goals with GROUP BY + SUM in the DB
        List<Long> matchIds = matches.stream().map(Match::getId).collect(Collectors.toList());
        Map<Long, Map<Long, Integer>> goalsMap = buildGoalsMap(matchIds);

        // 4. Single-pass aggregation in memory (no more DB calls)
        Set<Long> processedMatches = new HashSet<>();
        for (Match m : matches) {
            if (processedMatches.contains(m.getId())) continue;
            processedMatches.add(m.getId());

            Long homeId = m.getTeamHome().getId();
            Long awayId = (m.getTeamAway() != null) ? m.getTeamAway().getId() : null;

            Map<Long, Integer> matchGoals = goalsMap.getOrDefault(m.getId(), Map.of());
            int homeGoals = matchGoals.getOrDefault(homeId, 0);
            int awayGoals = 0;
            
            // Si hay equipo rival registrado, sacamos sus goles. 
            // Si es externo, no tenemos "ID" de equipo para buscar en el mapa de eventos, 
            // pero como no guardamos eventos de rivales externos, se queda en 0.
            if (awayId != null) {
                awayGoals = matchGoals.getOrDefault(awayId, 0);
            }

            updateStanding(table.get(homeId), homeGoals, awayGoals);
            if (awayId != null) {
                updateStanding(table.get(awayId), awayGoals, homeGoals);
            }
        }

        return table.values().stream()
                .sorted((a, b) -> {
                    if (b.getPuntos() != a.getPuntos()) return Integer.compare(b.getPuntos(), a.getPuntos());
                    if (b.getDiff() != a.getDiff()) return Integer.compare(b.getDiff(), a.getDiff());
                    return Integer.compare(b.getGf(), a.getGf());
                })
                .collect(Collectors.toList());
    }

    /**
     * Construye un mapa matchId -> teamId -> totalGoles usando la query agregada.
     * Reemplaza las N llamadas individuales a getGoalsForTeam().
     */
    private Map<Long, Map<Long, Integer>> buildGoalsMap(List<Long> matchIds) {
        List<GoalAggregationProjection> goalAggregations =
                matchEventRepository.findGoalsByMatchIds(matchIds, EventType.Gol);

        Map<Long, Map<Long, Integer>> goalsMap = new HashMap<>();
        for (GoalAggregationProjection g : goalAggregations) {
            goalsMap
                    .computeIfAbsent(g.getMatchId(), k -> new HashMap<>())
                    .put(g.getTeamId(), g.getTotalGoals() != null ? g.getTotalGoals().intValue() : 0);
        }
        return goalsMap;
    }

    private void updateStanding(StandingsDTO s, int gf, int gc) {
        if (s == null) return; // Equipo externo no presente en el club
        s.setPj(s.getPj() + 1);
        s.setGf(s.getGf() + gf);
        s.setGc(s.getGc() + gc);
        s.setDiff(s.getGf() - s.getGc());

        if (gf > gc) {
            s.setPg(s.getPg() + 1);
            s.setPuntos(s.getPuntos() + 3);
            s.getLastResults().add("V");
        } else if (gf == gc) {
            s.setPe(s.getPe() + 1);
            s.setPuntos(s.getPuntos() + 1);
            s.getLastResults().add("E");
        } else {
            s.setPp(s.getPp() + 1);
            s.getLastResults().add("D");
        }
        
        // Mantener solo los últimos 5
        if (s.getLastResults().size() > 5) {
            s.getLastResults().remove(0);
        }
    }

    private MatchHistoryDTO convertToHistoryDTO(Match m, Map<Long, Map<Long, Integer>> goalsMap) {
        MatchHistoryDTO dto = new MatchHistoryDTO();
        dto.setId(m.getId());
        dto.setTeamHomeNombre(m.getTeamHome().getNombre());
        dto.setTeamHomeEscudo(m.getTeamHome().getClub() != null ? m.getTeamHome().getClub().getLogo() : null);

        Map<Long, Integer> matchGoals = goalsMap.getOrDefault(m.getId(), Map.of());
        dto.setTeamHomeGoles(matchGoals.getOrDefault(m.getTeamHome().getId(), 0));

        if (m.getTeamAway() != null) {
            dto.setTeamAwayNombre(m.getTeamAway().getNombre());
            dto.setTeamAwayEscudo(m.getTeamAway().getClub() != null ? m.getTeamAway().getClub().getLogo() : null);
            dto.setTeamAwayGoles(matchGoals.getOrDefault(m.getTeamAway().getId(), 0));
        } else {
            dto.setTeamAwayNombre(m.getRivalNombre());
            dto.setTeamAwayEscudo(null);
            dto.setTeamAwayGoles(0); // No registramos goles de rivales externos en la DB
        }

        dto.setFecha(m.getFecha() != null ? m.getFecha().toString() : "");
        dto.setEstado(m.getEstado());
        return dto;
    }
}
