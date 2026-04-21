package es.sl1iickdev.loloapi.repositories;

import es.sl1iickdev.loloapi.models.Player;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlayerRepository extends JpaRepository<Player, Long> {
    // Spring genera: SELECT * FROM Players WHERE team_id = ?
    List<Player> findByTeamId(Long teamId);

    // --- IDOR Protection: validate team ownership before returning players ---
    List<Player> findByTeamIdAndTeamClubPropietarioId(Long teamId, Long propietarioId);
}