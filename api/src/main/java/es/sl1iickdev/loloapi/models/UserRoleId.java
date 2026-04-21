package es.sl1iickdev.loloapi.models;


import lombok.Data;

import java.io.Serializable;

// Clase para la clave compuesta necesaria en JPA para tablas intermedias con datos extra

@Data
public class UserRoleId implements Serializable {
    private Long userId;
    private Long roleId;
}
