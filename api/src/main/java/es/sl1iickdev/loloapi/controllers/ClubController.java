package es.sl1iickdev.loloapi.controllers;

import es.sl1iickdev.loloapi.dtos.ClubDTO;
import es.sl1iickdev.loloapi.services.ClubService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clubs")
@RequiredArgsConstructor
public class ClubController {
    private final ClubService clubService;

    @GetMapping
    public List<ClubDTO> getClubs() {
        return clubService.getAllClubs();
    }

    @GetMapping("/{id}")
    public ClubDTO getClubById(@PathVariable Long id) {
        return clubService.getClubById(id);
    }

    @PostMapping
    public ClubDTO createClub(@RequestBody ClubDTO dto) {
        return clubService.createClub(dto);
    }
}