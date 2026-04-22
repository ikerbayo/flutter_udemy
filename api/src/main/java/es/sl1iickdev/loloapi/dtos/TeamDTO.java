package es.sl1iickdev.loloapi.dtos;

import lombok.Data;

@Data
public class TeamDTO {
    private Long id;
    private String nombre;
    private String categoriaFutbol;
    private Long clubId;
    private String clubNombre;
    private String escudoUrl;
    private Integer totalJugadores;
    private Long parentTeamId;
}
