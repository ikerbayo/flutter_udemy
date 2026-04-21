package es.sl1iickdev.loloapi.controllers;

import es.sl1iickdev.loloapi.dtos.MatchEventBulkRequestDTO;
import es.sl1iickdev.loloapi.dtos.MatchEventDTO;
import es.sl1iickdev.loloapi.dtos.MatchEventRequestDTO;
import es.sl1iickdev.loloapi.services.MatchEventService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
public class MatchEventController {
    private final MatchEventService eventService;

    @PostMapping
    public ResponseEntity<String> postEvent(@RequestBody MatchEventRequestDTO dto) {
        eventService.createEvent(dto);
        return ResponseEntity.ok("Evento registrado con éxito");
    }

    @PostMapping("/sync")
    public ResponseEntity<String> syncEvents(@RequestBody MatchEventBulkRequestDTO bulk) {
        eventService.syncEvents(bulk);
        return ResponseEntity.ok("Sincronización masiva de eventos completada con éxito");
    }

    @GetMapping("/{matchId}")
    public List<MatchEventDTO> getEventsByMatch(@PathVariable Long matchId) {
        return eventService.getEventsByMatch(matchId);
    }
}