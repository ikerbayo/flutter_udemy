package es.sl1iickdev.loloapi.services;

import es.sl1iickdev.loloapi.dtos.TeamDTO;
import es.sl1iickdev.loloapi.models.Club;
import es.sl1iickdev.loloapi.models.Team;
import es.sl1iickdev.loloapi.models.User;
import es.sl1iickdev.loloapi.repositories.ClubRepository;
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
public class TeamService {

    private final TeamRepository teamRepository;
    private final ClubRepository clubRepository;

    public List<TeamDTO> getMyTeams() {
        User user = SecurityUtils.getCurrentUser();
        return teamRepository.findByClubPropietarioId(user.getId()).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<TeamDTO> getTeamsByClub(Long clubId) {
        User user = SecurityUtils.getCurrentUser();
        return teamRepository.findByClubIdAndClubPropietarioId(clubId, user.getId()).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TeamDTO getTeamById(Long id) {
        User user = SecurityUtils.getCurrentUser();
        Team team = teamRepository.findByIdAndClubPropietarioId(id, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este equipo"));
        return convertToDTO(team);
    }

    public TeamDTO createTeam(TeamDTO dto) {
        User user = SecurityUtils.getCurrentUser();

        if (dto.getClubId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Debes especificar el clubId");
        }

        Club miClub = clubRepository.findByIdAndPropietarioId(dto.getClubId(), user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permiso para crear un equipo en un Club que no administras"));

        Team team = new Team();
        team.setNombre(dto.getNombre());
        team.setCategoriaFutbol(dto.getCategoriaFutbol());
        team.setClub(miClub);

        Team saved = teamRepository.save(team);
        return convertToDTO(saved);
    }

    private TeamDTO convertToDTO(Team team) {
        TeamDTO dto = new TeamDTO();
        dto.setId(team.getId());
        dto.setNombre(team.getNombre());
        dto.setCategoriaFutbol(team.getCategoriaFutbol());
        if (team.getClub() != null) {
            dto.setClubId(team.getClub().getId());
            dto.setClubNombre(team.getClub().getNombre());
            dto.setEscudoUrl(team.getClub().getLogo());
        }
        dto.setTotalJugadores(team.getPlayers() != null ? team.getPlayers().size() : 0);
        return dto;
    }
}
