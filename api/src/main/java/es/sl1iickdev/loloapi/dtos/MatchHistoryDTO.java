package es.sl1iickdev.loloapi.dtos;

import lombok.Data;

@Data
public class MatchHistoryDTO {
    private Long id;
    private String teamHomeNombre;
    private String teamHomeEscudo;
    private int teamHomeGoles;
    
    private String teamAwayNombre;
    private String teamAwayEscudo;
    private int teamAwayGoles;
    
    private String fecha;
    private String estado;
}
