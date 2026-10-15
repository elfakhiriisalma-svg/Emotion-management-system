package com.medical.emotionmonitoring.dto;

import com.medical.emotionmonitoring.entity.EmotionType;
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
public class EmotionRecordRequest {

    @NotNull(message = "Emotion type is required")
    private EmotionType emotionType;

    @Min(value = 1, message = "Intensity level must be at least 1")
    @Max(value = 10, message = "Intensity level must be at most 10")
    private Integer intensityLevel;

    private String notes;
    private String location;
    private String triggerEvent;
    private String physicalSymptoms;
    private LocalDateTime recordedAt;
}

