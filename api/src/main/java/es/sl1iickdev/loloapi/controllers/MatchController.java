package es.sl1iickdev.loloapi.controllers;

import es.sl1iickdev.loloapi.dtos.MatchDTO;
import es.sl1iickdev.loloapi.services.MatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/matches")
@RequiredArgsConstructor
public class MatchController {
    private final MatchService matchService;

    @GetMapping
    public List<MatchDTO> getAll() {
        return matchService.getAllMatches();
    }

    @GetMapping("/{id}")
    public MatchDTO getMatchById(@PathVariable Long id) {
        return matchService.getMatchById(id);
    }

    @PatchMapping("/{id}/status")
    public MatchDTO updateStatus(@PathVariable Long id, @RequestParam String estado) {
        return matchService.updateMatchStatus(id, estado);
    }

    @PostMapping
    public ResponseEntity<MatchDTO> createMatch(@RequestBody MatchDTO dto) {
        return ResponseEntity.ok(matchService.createMatch(dto));
    }
}