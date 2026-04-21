package es.sl1iickdev.loloapi.dtos;

/**
 * Proyección de Spring Data para la query agregada de goles.
 * Retorna goles agrupados por partido y equipo usando GROUP BY + SUM en la DB.
 */
public interface GoalAggregationProjection {
    Long getMatchId();
    Long getTeamId();
    Long getTotalGoals();
}
