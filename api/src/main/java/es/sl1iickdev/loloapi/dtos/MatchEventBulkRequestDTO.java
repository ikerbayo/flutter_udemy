package es.sl1iickdev.loloapi.dtos;

import lombok.Data;
import java.util.List;

@Data
public class MatchEventBulkRequestDTO {
    private List<MatchEventRequestDTO> events;
}
