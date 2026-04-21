package es.sl1iickdev.loloapi.services;

import es.sl1iickdev.loloapi.dtos.MatchDTO;
import es.sl1iickdev.loloapi.models.Match;
import es.sl1iickdev.loloapi.models.Team;
import es.sl1iickdev.loloapi.models.User;
import es.sl1iickdev.loloapi.repositories.MatchRepository;
import es.sl1iickdev.loloapi.repositories.TeamRepository;
import es.sl1iickdev.loloapi.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MatchService {
    private final MatchRepository matchRepository;
    private final TeamRepository teamRepository;

    public List<MatchDTO> getAllMatches() {
        User user = SecurityUtils.getCurrentUser();
        return matchRepository.findAllByOwner(user.getId()).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public MatchDTO getMatchById(Long id) {
        User user = SecurityUtils.getCurrentUser();
        Match match = matchRepository.findByIdAndOwner(id, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este partido"));
        return convertToDTO(match);
    }

    public MatchDTO createMatch(MatchDTO dto) {
        User user = SecurityUtils.getCurrentUser();

        // El equipo local siempre debe pertenecer al usuario
        Team home = teamRepository.findByIdAndClubPropietarioId(dto.getTeamHomeId(), user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso al equipo local"));

        Match match = new Match();
        match.setTeamHome(home);
        match.setFecha(dto.getFecha());
        match.setEstado(dto.getEstado() != null ? dto.getEstado() : "Programado");

        // Rival: puede ser un equipo del sistema o un equipo externo por nombre
        if (dto.getTeamAwayId() != null) {
            // Rival registrado: validar que pertenece al usuario
            Team away = teamRepository.findByIdAndClubPropietarioId(dto.getTeamAwayId(), user.getId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso al equipo visitante"));
            match.setTeamAway(away);
            match.setRivalNombre(null);
        } else if (dto.getRivalNombre() != null && !dto.getRivalNombre().isBlank()) {
            // Rival externo: solo se guarda el nombre, sin FK a teams
            match.setTeamAway(null);
            match.setRivalNombre(dto.getRivalNombre().trim());
        } else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Debes especificar teamAwayId o rivalNombre para crear un partido");
        }

        Match saved = matchRepository.save(match);
        return convertToDTO(saved);
    }

    public MatchDTO updateMatchStatus(Long id, String nuevoEstado) {
        User user = SecurityUtils.getCurrentUser();
        Match match = matchRepository.findByIdAndOwner(id, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este partido"));
        match.setEstado(nuevoEstado);
        return convertToDTO(matchRepository.save(match));
    }

    private MatchDTO convertToDTO(Match match) {
        MatchDTO dto = new MatchDTO();
        dto.setId(match.getId());
        dto.setTeamHomeId(match.getTeamHome().getId());
        dto.setTeamHomeNombre(match.getTeamHome().getNombre());

        if (match.getTeamAway() != null) {
            // Rival registrado
            dto.setTeamAwayId(match.getTeamAway().getId());
            dto.setTeamAwayNombre(match.getTeamAway().getNombre());
            dto.setRivalNombre(null);
        } else {
            // Rival externo
            dto.setTeamAwayId(null);
            dto.setTeamAwayNombre(match.getRivalNombre());
            dto.setRivalNombre(match.getRivalNombre());
        }

        dto.setFecha(match.getFecha());
        dto.setEstado(match.getEstado());
        return dto;
    }
}