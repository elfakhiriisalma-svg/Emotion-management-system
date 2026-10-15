package com.medical.emotionmonitoring.service;

import com.medical.emotionmonitoring.dto.EmotionRecordRequest;
import com.medical.emotionmonitoring.dto.EmotionRecordResponse;
import com.medical.emotionmonitoring.entity.EmotionRecord;
import com.medical.emotionmonitoring.entity.EmotionType;
import com.medical.emotionmonitoring.entity.User;
import com.medical.emotionmonitoring.repository.EmotionRecordRepository;
import com.medical.emotionmonitoring.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EmotionRecordService {

    private final EmotionRecordRepository emotionRecordRepository;
    private final UserRepository userRepository;

    @Transactional
    public EmotionRecordResponse createEmotionRecord(Long userId, EmotionRecordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        EmotionRecord record = new EmotionRecord();
        record.setUser(user);
        record.setEmotionType(request.getEmotionType());
        record.setIntensityLevel(request.getIntensityLevel());
        record.setNotes(request.getNotes());
        record.setLocation(request.getLocation());
        record.setTriggerEvent(request.getTriggerEvent());
        record.setPhysicalSymptoms(request.getPhysicalSymptoms());
        record.setRecordedAt(request.getRecordedAt() != null ? request.getRecordedAt() : LocalDateTime.now());

        EmotionRecord savedRecord = emotionRecordRepository.save(record);
        return mapToResponse(savedRecord);
    }

    public EmotionRecordResponse getEmotionRecordById(Long id, Long userId) {
        EmotionRecord record = emotionRecordRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Emotion record not found"));

        if (!record.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized access to emotion record");
        }

        return mapToResponse(record);
    }

    public List<EmotionRecordResponse> getAllEmotionRecordsByUserId(Long userId) {
        List<EmotionRecord> records = emotionRecordRepository.findByUserIdOrderByRecordedAtDesc(userId);
        return records.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<EmotionRecordResponse> getEmotionRecordsByType(Long userId, EmotionType emotionType) {
        List<EmotionRecord> records = emotionRecordRepository.findByUserIdAndEmotionType(userId, emotionType);
        return records.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<EmotionRecordResponse> getEmotionRecordsByDateRange(Long userId, LocalDateTime startDate, LocalDateTime endDate) {
        List<EmotionRecord> records = emotionRecordRepository.findByUserIdAndDateRange(userId, startDate, endDate);
        return records.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public EmotionRecordResponse updateEmotionRecord(Long id, Long userId, EmotionRecordRequest request) {
        EmotionRecord record = emotionRecordRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Emotion record not found"));

        if (!record.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized access to emotion record");
        }

        record.setEmotionType(request.getEmotionType());
        record.setIntensityLevel(request.getIntensityLevel());
        record.setNotes(request.getNotes());
        record.setLocation(request.getLocation());
        record.setTriggerEvent(request.getTriggerEvent());
        record.setPhysicalSymptoms(request.getPhysicalSymptoms());
        if (request.getRecordedAt() != null) {
            record.setRecordedAt(request.getRecordedAt());
        }

        EmotionRecord updatedRecord = emotionRecordRepository.save(record);
        return mapToResponse(updatedRecord);
    }

    @Transactional
    public void deleteEmotionRecord(Long id, Long userId) {
        EmotionRecord record = emotionRecordRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Emotion record not found"));

        if (!record.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized access to emotion record");
        }

        emotionRecordRepository.delete(record);
    }

    private EmotionRecordResponse mapToResponse(EmotionRecord record) {
        EmotionRecordResponse response = new EmotionRecordResponse();
        response.setId(record.getId());
        response.setUserId(record.getUser().getId());
        response.setEmotionType(record.getEmotionType());
        response.setIntensityLevel(record.getIntensityLevel());
        response.setNotes(record.getNotes());
        response.setLocation(record.getLocation());
        response.setTriggerEvent(record.getTriggerEvent());
        response.setPhysicalSymptoms(record.getPhysicalSymptoms());
        response.setRecordedAt(record.getRecordedAt());
        response.setCreatedAt(record.getCreatedAt());
        response.setUpdatedAt(record.getUpdatedAt());
        return response;
    }
}

