package es.sl1iickdev.loloapi.models;

import jakarta.persistence.*;
import lombok.Data;


@Entity
@Data
@Table(name = "user_roles")
public class UserRole {

    @EmbeddedId
    private UserRoleId id;

    @ManyToOne
    @MapsId("roleId")
    @JoinColumn(name = "role_id")
    private Role role; // Gracias a @Data, esto genera automáticamente .getRole()

    @ManyToOne
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "entity_id")
    private Integer entityId;
}

