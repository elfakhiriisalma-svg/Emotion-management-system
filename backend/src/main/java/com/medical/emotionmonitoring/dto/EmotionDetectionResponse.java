package com.medical.emotionmonitoring.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmotionDetectionResponse {
    private String emotion;
    private Double confidence;
    private Map<String, Double> emotions; // All detected emotions with confidence scores
}

