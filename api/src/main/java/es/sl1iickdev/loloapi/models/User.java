package es.sl1iickdev.loloapi.models;

import jakarta.persistence.*;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

@Entity
@Data
@Table(name = "users")
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 150)
    private String email;

    @Column(name = "pwd", nullable = false)
    private String password;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Column(name = "avatar")
    private String foto;

    @Column(name = "max_clubs")
    private Integer maxClubs = 2;

    // Relación correcta para usar entityId de tu UserRole
    @OneToMany(mappedBy = "user", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<UserRole> roles;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        if (roles == null) return java.util.Collections.emptyList();
        return roles.stream()
                .map(userRole -> new SimpleGrantedAuthority("ROLE_" + userRole.getRole().getNombre().name()))
                .collect(Collectors.toList());
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}