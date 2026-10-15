package com.medical.emotionmonitoring.controller;

import com.medical.emotionmonitoring.dto.EmotionRecordRequest;
import com.medical.emotionmonitoring.dto.EmotionRecordResponse;
import com.medical.emotionmonitoring.entity.EmotionType;
import com.medical.emotionmonitoring.repository.UserRepository;
import com.medical.emotionmonitoring.service.EmotionRecordService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/emotion-records")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class EmotionRecordController {

    private final EmotionRecordService emotionRecordService;
    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<EmotionRecordResponse> createEmotionRecord(
            @Valid @RequestBody EmotionRecordRequest request) {
        try {
            Long userId = getCurrentUserId();
            EmotionRecordResponse response = emotionRecordService.createEmotionRecord(userId, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<EmotionRecordResponse> getEmotionRecordById(@PathVariable Long id) {
        try {
            Long userId = getCurrentUserId();
            EmotionRecordResponse response = emotionRecordService.getEmotionRecordById(id, userId);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @GetMapping
    public ResponseEntity<List<EmotionRecordResponse>> getAllEmotionRecords() {
        try {
            Long userId = getCurrentUserId();
            List<EmotionRecordResponse> responses = emotionRecordService.getAllEmotionRecordsByUserId(userId);
            return ResponseEntity.ok(responses);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/type/{emotionType}")
    public ResponseEntity<List<EmotionRecordResponse>> getEmotionRecordsByType(
            @PathVariable EmotionType emotionType) {
        try {
            Long userId = getCurrentUserId();
            List<EmotionRecordResponse> responses = emotionRecordService.getEmotionRecordsByType(userId, emotionType);
            return ResponseEntity.ok(responses);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/date-range")
    public ResponseEntity<List<EmotionRecordResponse>> getEmotionRecordsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        try {
            Long userId = getCurrentUserId();
            List<EmotionRecordResponse> responses = emotionRecordService.getEmotionRecordsByDateRange(
                    userId, startDate, endDate);
            return ResponseEntity.ok(responses);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<EmotionRecordResponse> updateEmotionRecord(
            @PathVariable Long id,
            @Valid @RequestBody EmotionRecordRequest request) {
        try {
            Long userId = getCurrentUserId();
            EmotionRecordResponse response = emotionRecordService.updateEmotionRecord(id, userId, request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEmotionRecord(@PathVariable Long id) {
        try {
            Long userId = getCurrentUserId();
            emotionRecordService.deleteEmotionRecord(id, userId);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof org.springframework.security.core.userdetails.UserDetails) {
            String email = ((org.springframework.security.core.userdetails.UserDetails) authentication.getPrincipal()).getUsername();
            return userRepository.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"))
                    .getId();
        }
        throw new RuntimeException("User not authenticated");
    }
}

