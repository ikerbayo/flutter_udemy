package es.sl1iickdev.loloapi.repositories;

import es.sl1iickdev.loloapi.dtos.GoalAggregationProjection;
import es.sl1iickdev.loloapi.models.EventType;
import es.sl1iickdev.loloapi.models.MatchEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MatchEventRepository extends JpaRepository<MatchEvent, Long> {

    List<MatchEvent> findByMatchIdOrderByMinutoAsc(Long matchId);

    // Para contar cuántos goles lleva un jugador en total
    long countByPlayerIdAndTipo(Long playerId, EventType tipo);

    // Para ver los eventos de un jugador específico (sus goles, tarjetas, etc.)
    List<MatchEvent> findByPlayerId(Long playerId);

    // --- Standings Optimization: aggregated goals with GROUP BY + SUM in the DB ---
    @Query("SELECT e.match.id as matchId, e.player.team.id as teamId, " +
           "SUM(COALESCE(e.valor, 1)) as totalGoals " +
           "FROM MatchEvent e " +
           "WHERE e.tipo = :tipo AND e.match.id IN :matchIds " +
           "GROUP BY e.match.id, e.player.team.id")
    List<GoalAggregationProjection> findGoalsByMatchIds(
            @Param("matchIds") List<Long> matchIds,
            @Param("tipo") EventType tipo);
}