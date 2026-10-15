package com.medical.emotionmonitoring.service;

import com.medical.emotionmonitoring.dto.EmotionDetectionResponse;
import com.medical.emotionmonitoring.dto.EmotionRequest;
import com.medical.emotionmonitoring.dto.EmotionResponse;
import com.medical.emotionmonitoring.entity.Alert;
import com.medical.emotionmonitoring.entity.Emotion;
import com.medical.emotionmonitoring.entity.EmotionTypeEnum;
import com.medical.emotionmonitoring.entity.Role;
import com.medical.emotionmonitoring.entity.User;
import com.medical.emotionmonitoring.exception.BusinessException;
import com.medical.emotionmonitoring.exception.EntityNotFoundException;
import com.medical.emotionmonitoring.repository.EmotionRepository;
import com.medical.emotionmonitoring.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmotionService {

    private final EmotionRepository emotionRepository;
    private final UserRepository userRepository;
    private final AlertService alertService;
    private final EmotionDetectionService emotionDetectionService;

    @Transactional
    public EmotionResponse createEmotion(Long employeeId, EmotionRequest request) {
        User employee = userRepository.findById(employeeId)
                .orElseThrow(() -> new EntityNotFoundException("Employee not found with id: " + employeeId));

        Emotion emotion = new Emotion();
        emotion.setEmotionType(request.getEmotionType());
        emotion.setConfidence(request.getConfidence());
        emotion.setEmployee(employee);
        emotion.setTimestamp(request.getTimestamp() != null ? request.getTimestamp() : LocalDateTime.now());

        Emotion savedEmotion = emotionRepository.save(emotion);

        // Create alert for every detected emotion
        createEmotionAlert(employeeId, savedEmotion);

        // Check for 3 consecutive SAD emotions and trigger alert (additional alert)
        checkAndTriggerSadAlert(employeeId);

        return mapToResponse(savedEmotion);
    }

    /**
     * Detect emotion from image and save it
     */
    @Transactional
    public EmotionResponse createEmotionFromImage(Long employeeId, MultipartFile imageFile) {
        User employee = userRepository.findById(employeeId)
                .orElseThrow(() -> new EntityNotFoundException("Employee not found with id: " + employeeId));

        // Detect emotion from image
        EmotionDetectionResponse detectionResponse = emotionDetectionService.detectEmotionFromImage(imageFile);
        
        // Map detected emotion to EmotionTypeEnum
        EmotionTypeEnum emotionType = emotionDetectionService.mapToEmotionTypeEnum(detectionResponse.getEmotion());
        Double confidence = detectionResponse.getConfidence();

        // Create emotion entity
        Emotion emotion = new Emotion();
        emotion.setEmotionType(emotionType);
        emotion.setConfidence(confidence);
        emotion.setEmployee(employee);
        emotion.setTimestamp(LocalDateTime.now());

        Emotion savedEmotion = emotionRepository.save(emotion);

        // Create alert for every detected emotion
        createEmotionAlert(employeeId, savedEmotion);

        // Check for 3 consecutive SAD emotions and trigger alert (additional alert)
        checkAndTriggerSadAlert(employeeId);

        log.info("Emotion detected from image for employee {}: {} with confidence {}", 
                employeeId, emotionType, confidence);

        return mapToResponse(savedEmotion);
    }

    /**
     * Create an alert for every detected emotion in real-time
     * Prevents duplicate alerts within a 30-second window for the same employee to avoid spam
     * This ensures real-time notification while preventing excessive alerts
     */
    private void createEmotionAlert(Long employeeId, Emotion emotion) {
        try {
            log.info("🔔 Attempting to create alert for employee {} - emotion: {}", employeeId, emotion.getEmotionType());
            
            // Check if an alert was already created recently (within last 30 seconds) to avoid spam
            // Reduced from 5 minutes to 30 seconds for real-time notifications
            List<Alert> recentAlerts = alertService.getAlertsByEmployeeId(employeeId);
            LocalDateTime thirtySecondsAgo = LocalDateTime.now().minusSeconds(30);
            
            boolean recentAlertExists = recentAlerts.stream()
                    .anyMatch(alert -> alert.getCreatedAt().isAfter(thirtySecondsAgo) 
                            && alert.getMessage().contains("New emotion detected")
                            && alert.getMessage().contains(emotion.getEmotionType().toString()));

            if (recentAlertExists) {
                log.debug("⚠️ Alert already exists for employee {} within the last 30 seconds for emotion {}, skipping duplicate alert", 
                        employeeId, emotion.getEmotionType());
                return;
            }

            User employee = userRepository.findById(employeeId)
                    .orElseThrow(() -> new EntityNotFoundException("Employee not found with id: " + employeeId));

            String emotionTypeName = emotion.getEmotionType().toString();
            String confidencePercent = String.format("%.1f%%", emotion.getConfidence() * 100);
            
            String message = String.format(
                    "New emotion detected: Employee %s has recorded a %s emotion with %s confidence.",
                    employee.getFullName(),
                    emotionTypeName,
                    confidencePercent
            );

            log.info("📤 Creating alert with message: {}", message);
            Alert createdAlert = alertService.createAlert(employeeId, message);
            log.info("✅ Real-time alert CREATED SUCCESSFULLY! Alert ID: {} for employee {} - emotion: {} (confidence: {})", 
                    createdAlert.getId(), employeeId, emotionTypeName, confidencePercent);
        } catch (EntityNotFoundException e) {
            log.error("❌ Entity not found while creating alert for employee {}: {}", employeeId, e.getMessage());
            // Don't throw exception - alert creation failure shouldn't break emotion creation
        } catch (RuntimeException e) {
            log.error("❌ Runtime error while creating alert for employee {}: {}", employeeId, e.getMessage());
            if (e.getMessage() != null && e.getMessage().contains("No manager available")) {
                log.warn("⚠️ WARNING: No manager available in the system! Please create a manager user first.");
            }
            // Don't throw exception - alert creation failure shouldn't break emotion creation
        } catch (Exception e) {
            log.error("❌ Unexpected error while creating alert for employee {}: {} - Stack trace: {}", 
                    employeeId, e.getMessage(), e);
            // Don't throw exception - alert creation failure shouldn't break emotion creation
        }
    }

    /**
     * Check if employee has 3 consecutive SAD emotions and trigger an alert
     * Only creates an alert if one hasn't been created recently for the same pattern
     */
    private void checkAndTriggerSadAlert(Long employeeId) {
        List<Emotion> recentEmotions = emotionRepository.findByEmployeeIdOrderByTimestampDesc(employeeId);

        // Check if we have at least 3 emotions
        if (recentEmotions.size() < 3) {
            return;
        }

        // Get the last 3 emotions (most recent first)
        List<Emotion> lastThreeEmotions = recentEmotions.subList(0, Math.min(3, recentEmotions.size()));

        // Check if all 3 are SAD
        boolean allSad = lastThreeEmotions.stream()
                .allMatch(e -> e.getEmotionType() == EmotionTypeEnum.SAD);

        if (allSad) {
            // Check if an alert was already created recently (within last hour) to avoid duplicates
            List<Alert> recentAlerts = alertService.getAlertsByEmployeeId(employeeId);
            LocalDateTime oneHourAgo = LocalDateTime.now().minusHours(1);
            
            boolean recentAlertExists = recentAlerts.stream()
                    .anyMatch(alert -> alert.getCreatedAt().isAfter(oneHourAgo) 
                            && alert.getMessage().contains("3 consecutive SAD emotions"));

            if (recentAlertExists) {
                log.debug("Alert already exists for employee {} within the last hour, skipping duplicate alert", employeeId);
                return;
            }

            User employee = userRepository.findById(employeeId)
                    .orElseThrow(() -> new EntityNotFoundException("Employee not found with id: " + employeeId));

            String message = String.format(
                    "Alert: Employee %s has recorded 3 consecutive SAD emotions. Please review their emotional state.",
                    employee.getFullName()
            );

            try {
                alertService.createAlert(employeeId, message);
                log.info("Alert created for employee {} due to 3 consecutive SAD emotions", employeeId);
            } catch (Exception e) {
                log.error("Failed to create alert for employee {}: {}", employeeId, e.getMessage());
                // Don't throw exception - alert creation failure shouldn't break emotion creation
            }
        }
    }

    public EmotionResponse getEmotionById(Long id, Long employeeId) {
        Emotion emotion = emotionRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Emotion not found with id: " + id));

        if (!emotion.getEmployee().getId().equals(employeeId)) {
            throw new BusinessException("Unauthorized access to emotion");
        }

        return mapToResponse(emotion);
    }

    public List<EmotionResponse> getEmotionHistoryByEmployeeId(Long employeeId, Long currentUserId, Role currentUserRole) {
        // Check if employee exists
        if (!userRepository.existsById(employeeId)) {
            throw new EntityNotFoundException("Employee not found with id: " + employeeId);
        }

        // Authorization check: Employees can only view their own history, Managers can view any employee's history
        if (currentUserRole == Role.EMPLOYEE && !employeeId.equals(currentUserId)) {
            throw new BusinessException("Unauthorized: Employees can only view their own emotion history");
        }

        List<Emotion> emotions = emotionRepository.findByEmployeeIdOrderByTimestampDesc(employeeId);
        return emotions.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private EmotionResponse mapToResponse(Emotion emotion) {
        EmotionResponse response = new EmotionResponse();
        response.setId(emotion.getId());
        response.setEmotionType(emotion.getEmotionType());
        response.setConfidence(emotion.getConfidence());
        response.setTimestamp(emotion.getTimestamp());
        response.setEmployeeId(emotion.getEmployee().getId());
        response.setEmployeeName(emotion.getEmployee().getFullName());
        return response;
    }
}

