package com.medical.emotionmonitoring.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmotionDetectionRequest {
    private String imageBase64;
    private String imageUrl; // Alternative: URL to image
}

