package com.medical.emotionmonitoring.service;

import com.medical.emotionmonitoring.dto.EmotionStatisticsResponse;
import com.medical.emotionmonitoring.entity.Emotion;
import com.medical.emotionmonitoring.entity.EmotionTypeEnum;
import com.medical.emotionmonitoring.repository.EmotionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EmotionStatisticsService {

    private final EmotionRepository emotionRepository;

    public EmotionStatisticsResponse getEmployeeStatistics(Long employeeId) {
        List<Emotion> emotions = emotionRepository.findByEmployeeIdOrderByTimestampDesc(employeeId);
        
        if (emotions.isEmpty()) {
            return new EmotionStatisticsResponse(
                    "NEUTRAL", 0, new HashMap<>(), new HashMap<>(), 0.0, 0, 0
            );
        }

        // Calculate emotion frequency
        Map<String, Integer> emotionFrequency = new HashMap<>();
        for (Emotion emotion : emotions) {
            String emotionType = emotion.getEmotionType().name();
            emotionFrequency.put(emotionType, emotionFrequency.getOrDefault(emotionType, 0) + 1);
        }

        // Find most frequent emotion
        String mostFrequentEmotion = emotionFrequency.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("NEUTRAL");
        Integer mostFrequentEmotionCount = emotionFrequency.getOrDefault(mostFrequentEmotion, 0);

        // Calculate weekly emotion count (last 7 days)
        Map<String, Integer> weeklyEmotionCount = new HashMap<>();
        LocalDateTime weekAgo = LocalDateTime.now().minus(7, ChronoUnit.DAYS);
        for (Emotion emotion : emotions) {
            if (emotion.getTimestamp().isAfter(weekAgo)) {
                DayOfWeek dayOfWeek = emotion.getTimestamp().getDayOfWeek();
                String dayName = dayOfWeek.name();
                weeklyEmotionCount.put(dayName, weeklyEmotionCount.getOrDefault(dayName, 0) + 1);
            }
        }

        // Calculate average confidence
        Double averageConfidence = emotions.stream()
                .mapToDouble(Emotion::getConfidence)
                .average()
                .orElse(0.0);

        // Calculate stress level (0-100)
        // Based on percentage of negative emotions (SAD, ANGRY, FEAR)
        long negativeEmotionsCount = emotions.stream()
                .filter(e -> e.getEmotionType() == EmotionTypeEnum.SAD ||
                            e.getEmotionType() == EmotionTypeEnum.ANGRY ||
                            e.getEmotionType() == EmotionTypeEnum.FEAR)
                .count();
        Integer stressLevel = (int) Math.round((negativeEmotionsCount * 100.0) / emotions.size());

        return new EmotionStatisticsResponse(
                mostFrequentEmotion,
                mostFrequentEmotionCount,
                emotionFrequency,
                weeklyEmotionCount,
                averageConfidence,
                emotions.size(),
                stressLevel
        );
    }
}


