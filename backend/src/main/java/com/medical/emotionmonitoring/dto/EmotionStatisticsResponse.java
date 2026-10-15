package com.medical.emotionmonitoring.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmotionStatisticsResponse {
    private String mostFrequentEmotion;
    private Integer mostFrequentEmotionCount;
    private Map<String, Integer> emotionFrequency; // emotionType -> count
    private Map<String, Integer> weeklyEmotionCount; // dayOfWeek -> count
    private Double averageConfidence;
    private Integer totalEmotions;
    private Integer stressLevel; // 0-100 based on SAD/ANGRY/FEAR emotions
}


