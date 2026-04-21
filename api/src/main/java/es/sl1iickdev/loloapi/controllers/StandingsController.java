package es.sl1iickdev.loloapi.controllers;

import es.sl1iickdev.loloapi.dtos.MatchHistoryDTO;
import es.sl1iickdev.loloapi.dtos.StandingsDTO;
import es.sl1iickdev.loloapi.services.StandingsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/standings")
@RequiredArgsConstructor
public class StandingsController {

    private final StandingsService standingsService;

    @GetMapping("/club/{clubId}")
    public List<StandingsDTO> getStandingsByClub(@PathVariable Long clubId) {
        return standingsService.getStandingsByClub(clubId);
    }

    @GetMapping("/my-standings")
    public List<StandingsDTO> getMyStandings() {
        return standingsService.getMyStandings();
    }

    @GetMapping("/team/{teamId}/history")
    public List<MatchHistoryDTO> getMatchHistory(@PathVariable Long teamId) {
        return standingsService.getMatchHistory(teamId);
    }
}
