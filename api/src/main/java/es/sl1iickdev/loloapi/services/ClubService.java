package es.sl1iickdev.loloapi.services;

import es.sl1iickdev.loloapi.dtos.ClubDTO;
import es.sl1iickdev.loloapi.models.Club;
import es.sl1iickdev.loloapi.models.User;
import es.sl1iickdev.loloapi.repositories.ClubRepository;
import es.sl1iickdev.loloapi.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ClubService {
    private final ClubRepository clubRepository;

    public List<ClubDTO> getAllClubs() {
        User user = SecurityUtils.getCurrentUser();
        return clubRepository.findAllByPropietarioId(user.getId()).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public ClubDTO getClubById(Long id) {
        User user = SecurityUtils.getCurrentUser();
        Club club = clubRepository.findByIdAndPropietarioId(id, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este club"));
        return convertToDTO(club);
    }

    public ClubDTO createClub(ClubDTO dto) {
        User user = SecurityUtils.getCurrentUser();

        long userClubsCount = clubRepository.countByPropietarioId(user.getId());
        Integer limite = user.getMaxClubs() != null ? user.getMaxClubs() : 2;
        if (userClubsCount >= limite) {
             throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Has alcanzado el límite máximo de clubes permitidos (" + limite + "). Contacta con soporte para ampliarlo.");
        }

        Club club = new Club();
        club.setNombre(dto.getNombre());
        club.setLogo(dto.getLogo());
        club.setPropietario(user);

        return convertToDTO(clubRepository.save(club));
    }

    private ClubDTO convertToDTO(Club club) {
        ClubDTO dto = new ClubDTO();
        dto.setId(club.getId());
        dto.setNombre(club.getNombre());
        dto.setLogo(club.getLogo());
        dto.setTotalEquipos(club.getTeams() != null ? club.getTeams().size() : 0);
        return dto;
    }
}