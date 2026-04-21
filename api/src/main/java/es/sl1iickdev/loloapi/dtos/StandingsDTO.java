package es.sl1iickdev.loloapi.dtos;

import lombok.Data;
import java.util.List;

@Data
public class StandingsDTO {
    private Long teamId;
    private String teamNombre;
    private String escudoUrl;
    private int pj; // Partidos Jugados
    private int pg; // Partidos Ganados
    private int pe; // Partidos Empatados
    private int pp; // Partidos Perdidos
    private int gf; // Goles a Favor
    private int gc; // Goles en Contra
    private int diff; // Diferencia (gf - gc)
    private int puntos; // Puntos
    
    /** Últimos resultados: 'V' (Victoria), 'E' (Empate), 'D' (Derrota) */
    private List<String> lastResults;
}
