package es.sl1iickdev.loloapi.controllers;

import es.sl1iickdev.loloapi.dtos.PlayerDTO;
import es.sl1iickdev.loloapi.services.PlayerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/players")
@RequiredArgsConstructor
public class PlayerController {

    private final PlayerService playerService;

    @GetMapping("/team/{teamId}")
    public List<PlayerDTO> getByTeam(@PathVariable Long teamId) {
        return playerService.getPlayersByTeam(teamId);
    }

    @GetMapping("/{id}")
    public PlayerDTO getPlayerById(@PathVariable Long id) {
        return playerService.getPlayerById(id);
    }

    @PostMapping
    public ResponseEntity<PlayerDTO> createPlayer(@RequestBody PlayerDTO dto) {
        return ResponseEntity.ok(playerService.createPlayer(dto));
    }
}