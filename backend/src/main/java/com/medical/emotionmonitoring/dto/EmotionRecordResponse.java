package com.medical.emotionmonitoring.dto;

import com.medical.emotionmonitoring.entity.EmotionType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmotionRecordResponse {
    private Long id;
    private Long userId;
    private EmotionType emotionType;
    private Integer intensityLevel;
    private String notes;
    private String location;
    private String triggerEvent;
    private String physicalSymptoms;
    private LocalDateTime recordedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

