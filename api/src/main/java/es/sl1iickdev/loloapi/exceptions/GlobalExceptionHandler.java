package es.sl1iickdev.loloapi.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, Object>> handleResponseStatusException(ResponseStatusException ex) {
        Map<String, Object> errorParams = new HashMap<>();
        errorParams.put("status", ex.getStatusCode().value());
        errorParams.put("error", ex.getReason());
        return new ResponseEntity<>(errorParams, ex.getStatusCode());
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, Object>> handleRuntimeException(RuntimeException ex) {
        Map<String, Object> errorParams = new HashMap<>();
        errorParams.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());
        errorParams.put("error", ex.getMessage());
        return new ResponseEntity<>(errorParams, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
