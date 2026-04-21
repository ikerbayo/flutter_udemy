package es.sl1iickdev.loloapi.models;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "roles")
@Data
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private RoleName nombre; // <--- Este es el campo que queremos leer

    public enum RoleName {
        Admin, Padre
    }
}