package es.sl1iickdev.loloapi.security;

import es.sl1iickdev.loloapi.models.User;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.server.ResponseStatusException;

/**
 * Utilidad centralizada para extraer el usuario autenticado del SecurityContext.
 * Elimina la duplicación del boilerplate de SecurityContextHolder en los servicios.
 */
public final class SecurityUtils {

    private SecurityUtils() {
        // Utility class — no instantiation
    }

    /**
     * Obtiene el User autenticado del contexto de seguridad.
     * El JwtAuthenticationFilter almacena la entidad User (que implementa UserDetails)
     * como principal, por lo que el cast directo es seguro.
     *
     * @return El User autenticado
     * @throws ResponseStatusException 401 si no hay usuario autenticado
     */
    public static User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User user) {
            return user;
        }
        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "No autenticado");
    }
}
