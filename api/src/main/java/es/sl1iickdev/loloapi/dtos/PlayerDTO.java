package es.sl1iickdev.loloapi.dtos;

import lombok.Data;

@Data
public class PlayerDTO {
    private Long id;
    private String nombre;
    private Integer dorsal;
    private String posicion;
    private String foto;
    private Long teamId;      // Referencia simple al equipo
    private String teamNombre; // Para que el frontend no tenga que preguntar "¿qué equipo es el ID 5?"
}