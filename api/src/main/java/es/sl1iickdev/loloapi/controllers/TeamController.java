package es.sl1iickdev.loloapi.controllers;

import es.sl1iickdev.loloapi.dtos.TeamDTO;
import es.sl1iickdev.loloapi.services.TeamService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/teams")
@RequiredArgsConstructor
public class TeamController {

    private final TeamService teamService;

    @GetMapping("/my-teams")
    public List<TeamDTO> getMyTeams() {
        return teamService.getMyTeams();
    }

    @GetMapping("/club/{clubId}")
    public List<TeamDTO> getTeamsByClub(@PathVariable Long clubId) {
        return teamService.getTeamsByClub(clubId);
    }

    @GetMapping("/{teamId}/rivals")
    public List<TeamDTO> getRivalesByTeam(@PathVariable Long teamId) {
        return teamService.getRivalesByTeam(teamId);
    }

    @GetMapping("/{id}")
    public TeamDTO getTeamById(@PathVariable Long id) {
        return teamService.getTeamById(id);
    }

    @PostMapping
    public ResponseEntity<TeamDTO> createTeam(@RequestBody TeamDTO dto) {
        return ResponseEntity.ok(teamService.createTeam(dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTeam(@PathVariable Long id) {
        teamService.deleteTeam(id);
        return ResponseEntity.noContent().build();
    }
}
