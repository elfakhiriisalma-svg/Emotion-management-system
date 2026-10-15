package com.medical.emotionmonitoring.dto;

import com.medical.emotionmonitoring.entity.EmotionTypeEnum;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmotionResponse {
    private Long id;
    private EmotionTypeEnum emotionType;
    private Double confidence;
    private LocalDateTime timestamp;
    private Long employeeId;
    private String employeeName;
}

