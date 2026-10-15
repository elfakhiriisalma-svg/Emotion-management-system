package com.medical.emotionmonitoring.dto;

import com.medical.emotionmonitoring.entity.EmotionTypeEnum;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmotionRequest {

    @NotNull(message = "Emotion type is required")
    private EmotionTypeEnum emotionType;

    @NotNull(message = "Confidence is required")
    @Min(value = 0, message = "Confidence must be at least 0")
    @Max(value = 1, message = "Confidence must be at most 1")
    private Double confidence;

    private LocalDateTime timestamp;
}

