package es.sl1iickdev.loloapi.services;

import es.sl1iickdev.loloapi.dtos.PlayerDTO;
import es.sl1iickdev.loloapi.models.Player;
import es.sl1iickdev.loloapi.models.Team;
import es.sl1iickdev.loloapi.models.User;
import es.sl1iickdev.loloapi.repositories.PlayerRepository;
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
public class PlayerService {

    private final PlayerRepository playerRepository;
    private final TeamRepository teamRepository;

    public List<PlayerDTO> getPlayersByTeam(Long teamId) {
        User user = SecurityUtils.getCurrentUser();
        // IDOR: validate the team belongs to the authenticated user
        teamRepository.findByIdAndClubPropietarioId(teamId, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este equipo"));
        return playerRepository.findByTeamId(teamId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public PlayerDTO getPlayerById(Long id) {
        User user = SecurityUtils.getCurrentUser();
        Player player = playerRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Jugador no encontrado"));
        // IDOR: validate ownership through player -> team -> club -> propietario
        if (player.getTeam() == null || player.getTeam().getClub() == null ||
                !player.getTeam().getClub().getPropietario().getId().equals(user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este jugador");
        }
        return convertToDTO(player);
    }

    public PlayerDTO createPlayer(PlayerDTO dto) {
        User user = SecurityUtils.getCurrentUser();

        if (dto.getTeamId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Debes especificar el teamId");
        }

        // IDOR: validate the target team belongs to the authenticated user
        Team team = teamRepository.findByIdAndClubPropietarioId(dto.getTeamId(), user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permiso para añadir jugadores a un equipo que no administras"));

        Player player = new Player();
        player.setNombre(dto.getNombre());
        if (dto.getDorsal() != null) {
            player.setDorsal(dto.getDorsal());
        }
        player.setPosicionPrincipal(dto.getPosicion());
        player.setFoto(dto.getFoto());
        player.setTeam(team);

        Player saved = playerRepository.save(player);
        return convertToDTO(saved);
    }

    private PlayerDTO convertToDTO(Player player) {
        PlayerDTO dto = new PlayerDTO();
        dto.setId(player.getId());
        dto.setNombre(player.getNombre());
        dto.setDorsal(player.getDorsal());
        dto.setPosicion(player.getPosicionPrincipal());
        dto.setFoto(player.getFoto());

        if (player.getTeam() != null) {
            dto.setTeamId(player.getTeam().getId());
            dto.setTeamNombre(player.getTeam().getNombre());
        }
        return dto;
    }
}