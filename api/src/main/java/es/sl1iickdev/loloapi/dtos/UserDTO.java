package es.sl1iickdev.loloapi.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder // El Builder te salvará la vida para evitar errores de constructor
public class UserDTO {
    private Long id;
    private String nombre;
    private String email;
    private String foto;
    private List<String> roles;
}