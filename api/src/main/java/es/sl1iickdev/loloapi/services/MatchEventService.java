package es.sl1iickdev.loloapi.services;

import es.sl1iickdev.loloapi.dtos.MatchEventBulkRequestDTO;
import es.sl1iickdev.loloapi.dtos.MatchEventDTO;
import es.sl1iickdev.loloapi.dtos.MatchEventRequestDTO;
import es.sl1iickdev.loloapi.models.Match;
import es.sl1iickdev.loloapi.models.MatchEvent;
import es.sl1iickdev.loloapi.models.Player;
import es.sl1iickdev.loloapi.models.EventType;
import es.sl1iickdev.loloapi.models.User;
import es.sl1iickdev.loloapi.repositories.MatchEventRepository;
import es.sl1iickdev.loloapi.repositories.MatchRepository;
import es.sl1iickdev.loloapi.repositories.PlayerRepository;
import es.sl1iickdev.loloapi.security.SecurityUtils;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MatchEventService {

    private final MatchEventRepository eventRepository;
    private final MatchRepository matchRepository;
    private final PlayerRepository playerRepository;

    @Transactional
    public void createEvent(MatchEventRequestDTO dto) {
        User user = SecurityUtils.getCurrentUser();

        // IDOR: validate the match belongs to the authenticated user
        Match match = matchRepository.findByIdAndOwner(dto.getMatchId(), user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este partido"));

        Player player = playerRepository.findById(dto.getPlayerId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Jugador con ID " + dto.getPlayerId() + " no encontrado"));

        MatchEvent event = new MatchEvent();
        event.setMatch(match);
        event.setPlayer(player);
        event.setMinuto(dto.getMinuto());
        event.setValor(dto.getValor() != null ? dto.getValor() : 1);

        if (dto.getTipo() != null && dto.getTipo().equalsIgnoreCase("Personalizado")) {
            event.setDescripcionPersonalizada(dto.getDescripcionPersonalizada());
            // Seguridad: usar el usuario autenticado en lugar de confiar en el ID del cliente
            event.setCreadoPorUser(user);
        }

        try {
            event.setTipo(EventType.valueOf(dto.getTipo()));
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tipo de evento no válido: " + dto.getTipo());
        }

        eventRepository.save(event);
    }

    @Transactional
    public void syncEvents(MatchEventBulkRequestDTO bulk) {
        if (bulk.getEvents() == null || bulk.getEvents().isEmpty()) return;

        for (MatchEventRequestDTO dto : bulk.getEvents()) {
            try {
                // Si el jugador no existe (rival externo sin jugadores reales),
                // ignoramos el evento en lugar de lanzar excepción.
                if (dto.getPlayerId() == null || !playerRepository.existsById(dto.getPlayerId())) {
                    continue;
                }
                createEvent(dto);
            } catch (Exception e) {
                // Tolerancia: un evento inválido no aborta la sincronización completa
            }
        }
    }

    public List<MatchEventDTO> getEventsByMatch(Long matchId) {
        User user = SecurityUtils.getCurrentUser();
        // IDOR: validate the match belongs to the authenticated user
        matchRepository.findByIdAndOwner(matchId, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a los eventos de este partido"));

        return eventRepository.findByMatchIdOrderByMinutoAsc(matchId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private MatchEventDTO convertToDTO(MatchEvent event) {
        MatchEventDTO dto = new MatchEventDTO();
        dto.setId(event.getId());
        dto.setTipo(event.getTipo().name());
        dto.setMinuto(event.getMinuto());
        dto.setValor(event.getValor() != null ? event.getValor() : 1);
        if (event.getPlayer() != null) {
            dto.setPlayerId(event.getPlayer().getId());
            dto.setPlayerNombre(event.getPlayer().getNombre());
        }

        if (event.getDescripcionPersonalizada() != null) {
            dto.setDescripcionPersonalizada(event.getDescripcionPersonalizada());
        }
        if (event.getCreadoPorUser() != null) {
            dto.setCreadoPorUserId(event.getCreadoPorUser().getId());
        }

        return dto;
    }
}