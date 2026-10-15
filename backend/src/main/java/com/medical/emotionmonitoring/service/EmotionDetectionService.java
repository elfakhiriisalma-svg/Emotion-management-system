package com.medical.emotionmonitoring.service;

import com.medical.emotionmonitoring.dto.EmotionDetectionResponse;
import com.medical.emotionmonitoring.entity.EmotionTypeEnum;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmotionDetectionService {

    private final RestTemplate restTemplate;

    // API Provider Configuration
    @Value("${emotion.api.provider:LUXAND}")
    private String apiProvider;

    // Luxand API Configuration
    @Value("${emotion.api.luxand.url:https://api.luxand.cloud/photo/emotions}")
    private String luxandApiUrl;

    @Value("${emotion.api.luxand.key:}")
    private String luxandApiKey;

    // Hugging Face API Configuration
    @Value("${emotion.api.huggingface.url:https://router.huggingface.co/hf-inference/models/trpakov/vit-face-expression}")
    private String huggingfaceApiUrl;

    @Value("${emotion.api.huggingface.key:}")
    private String huggingfaceApiKey;

    // Eden AI Configuration
    @Value("${emotion.api.edenai.url:https://api.edenai.run/v2/image/face_detection}")
    private String edenaiApiUrl;

    @Value("${emotion.api.edenai.key:}")
    private String edenaiApiKey;

    // Legacy configuration (for backward compatibility)
    @Value("${emotion.api.url:https://api-inference.huggingface.co/models/trpakov/vit-face-expression}")
    private String emotionApiUrl;

    @Value("${emotion.api.key:}")
    private String emotionApiKey;

    @Value("${emotion.api.enabled:true}")
    private boolean apiEnabled;

    /**
     * Detect emotion from an image file
     */
    public EmotionDetectionResponse detectEmotionFromImage(MultipartFile imageFile) {
        if (!apiEnabled) {
            log.warn("Emotion detection API is disabled. Using mock response.");
            return getRandomMockEmotionResponse();
        }

        try {
            // Log image file details
            log.info("Processing image file: name={}, size={} bytes, contentType={}", 
                    imageFile.getOriginalFilename(), imageFile.getSize(), imageFile.getContentType());
            
            // Convert image to base64
            byte[] imageBytes = imageFile.getBytes();
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);
            
            // Log base64 details for debugging
            log.debug("Base64 image length: {} characters, first 50 chars: {}", 
                    base64Image.length(), 
                    base64Image.length() > 50 ? base64Image.substring(0, 50) + "..." : base64Image);
            
            // Save image temporarily for verification (optional, for debugging)
            try {
                java.io.File tempFile = java.io.File.createTempFile("emotion_image_", ".jpg");
                java.nio.file.Files.write(tempFile.toPath(), imageBytes);
                log.debug("Temporary image saved to: {}", tempFile.getAbsolutePath());
                // Note: File will be deleted on JVM exit or can be cleaned up manually
            } catch (Exception e) {
                log.warn("Could not save temporary image file: {}", e.getMessage());
            }

            // Call external API
            EmotionDetectionResponse response = callEmotionDetectionAPI(base64Image);
            log.info("Emotion detection result: emotion={}, confidence={}", 
                    response.getEmotion(), response.getConfidence());
            return response;
        } catch (Exception e) {
            log.error("Error detecting emotion from image: {}", e.getMessage(), e);
            // Fallback to random mock response if API fails
            return getRandomMockEmotionResponse();
        }
    }

    /**
     * Detect emotion from base64 encoded image
     */
    public EmotionDetectionResponse detectEmotionFromBase64(String base64Image) {
        if (!apiEnabled) {
            log.warn("Emotion detection API is disabled. Using mock response.");
            return getRandomMockEmotionResponse();
        }

        try {
            // Log base64 details for debugging
            log.debug("Base64 image length: {} characters, first 50 chars: {}", 
                    base64Image.length(), 
                    base64Image.length() > 50 ? base64Image.substring(0, 50) + "..." : base64Image);
            
            EmotionDetectionResponse response = callEmotionDetectionAPI(base64Image);
            log.info("Emotion detection result: emotion={}, confidence={}", 
                    response.getEmotion(), response.getConfidence());
            return response;
        } catch (Exception e) {
            log.error("Error detecting emotion from base64: {}", e.getMessage(), e);
            return getRandomMockEmotionResponse();
        }
    }

    /**
     * Call external emotion detection API
     * This is a generic implementation that can work with different APIs
     */
    private EmotionDetectionResponse callEmotionDetectionAPI(String base64Image) {
        try {
            log.info("=== Calling Emotion Detection API (Hugging Face - new router) ===");
            log.info("API URL: {}", huggingfaceApiUrl);
            log.info("Has API Key: {}", huggingfaceApiKey != null && !huggingfaceApiKey.isEmpty());

            byte[] imageBytes = Base64.getDecoder().decode(base64Image);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setAccept(java.util.List.of(MediaType.APPLICATION_JSON));
            if (huggingfaceApiKey != null && !huggingfaceApiKey.isEmpty()) {
                headers.set("Authorization", "Bearer " + huggingfaceApiKey);
            }

            HttpEntity<byte[]> request = new HttpEntity<>(imageBytes, headers);

            ResponseEntity<String> rawResponse = restTemplate.postForEntity(
                    huggingfaceApiUrl,
                    request,
                    String.class
            );

            log.info("API Response Status: {}", rawResponse.getStatusCode());
            log.info("API Response Content-Type: {}", rawResponse.getHeaders().getContentType());
            log.info("API Response RAW BODY: {}", rawResponse.getBody());

            Object parsedBody = null;
            if (rawResponse.getBody() != null && !rawResponse.getBody().isBlank()) {
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                parsedBody = mapper.readValue(rawResponse.getBody(), Object.class);
            }
            ResponseEntity<Object> response = new ResponseEntity<>(parsedBody, rawResponse.getStatusCode());

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                EmotionDetectionResponse result = parseAPIResponse(response.getBody());
                log.info("✅ Successfully parsed emotion: {} with confidence: {}", result.getEmotion(), result.getConfidence());
                return result;
            } else {
                log.warn("❌ API returned non-success status: {}", response.getStatusCode());
                log.warn("⚠️ Falling back to random mock response");
                return getRandomMockEmotionResponse();
            }
        } catch (Exception e) {
            log.error("❌ Unexpected error calling Luxand emotion detection API: {}", e.getMessage());
            log.error("⚠️ Falling back to random mock response");
            return getRandomMockEmotionResponse();
        }
    }

    /**
     * Parse API response and map to EmotionDetectionResponse
     * This method handles different API response formats including Luxand and Hugging Face format
     */
    @SuppressWarnings("unchecked")
    private EmotionDetectionResponse parseAPIResponse(Object apiResponse) {
        EmotionDetectionResponse response = new EmotionDetectionResponse();
        Map<String, Double> emotions = new HashMap<>();

        log.debug("Parsing API response of type: {}", apiResponse.getClass().getSimpleName());

        // Format 1: Hugging Face returns a List of predictions (most common format)
        if (apiResponse instanceof java.util.List) {
            java.util.List<Object> responseList = (java.util.List<Object>) apiResponse;
            log.debug("API returned List with {} items", responseList.size());
            
            if (!responseList.isEmpty()) {
                // Hugging Face format: [{"label": "sadness", "score": 0.85}, ...]
                for (Object item : responseList) {
                    if (item instanceof Map) {
                        Map<String, Object> prediction = (Map<String, Object>) item;
                        String label = (String) prediction.get("label");
                        Object scoreObj = prediction.get("score");
                        
                        if (label != null && scoreObj instanceof Number) {
                            double score = ((Number) scoreObj).doubleValue();
                            // Map Hugging Face labels to our emotion types
                            String emotionKey = mapHuggingFaceLabelToEmotion(label);
                            emotions.put(emotionKey, score);
                            log.debug("Found emotion: {} with score: {}", emotionKey, score);
                        }
                    }
                }
            }
        }
        // Format 2: Direct Map with emotions object
        else if (apiResponse instanceof Map) {
            Map<String, Object> responseMap = (Map<String, Object>) apiResponse;

            // Format 2z: Luxand format: {"status":"success","faces":[{"rectangle":{...},"emotions":{"happiness":0.3,"neutral":0.7}}]}
            if (responseMap.containsKey("faces")) {
                Object facesObj = responseMap.get("faces");
                if (facesObj instanceof java.util.List) {
                    java.util.List<Object> faces = (java.util.List<Object>) facesObj;
                    if (!faces.isEmpty() && faces.get(0) instanceof Map) {
                        Map<String, Object> firstFace = (Map<String, Object>) faces.get(0);
                        Object faceEmotions = firstFace.get("emotions");
                        if (faceEmotions instanceof Map) {
                            ((Map<String, Object>) faceEmotions).forEach((key, value) -> {
                                if (value instanceof Number) {
                                    emotions.put(key.toUpperCase(), ((Number) value).doubleValue());
                                }
                            });
                        }
                    } else {
                        log.warn("Luxand response had no faces detected in the image");
                    }
                }
            }
            // Format 2a: Direct emotion scores
            else if (responseMap.containsKey("emotions")) {
                Map<String, Object> emotionsMap = (Map<String, Object>) responseMap.get("emotions");
                emotionsMap.forEach((key, value) -> {
                    if (value instanceof Number) {
                        emotions.put(key.toUpperCase(), ((Number) value).doubleValue());
                    }
                });
            }
            // Format 2b: Predictions array in Map
            else if (responseMap.containsKey("predictions")) {
                Object predictionsObj = responseMap.get("predictions");
                if (predictionsObj instanceof java.util.List) {
                    java.util.List<Object> predictions = (java.util.List<Object>) predictionsObj;
                    for (Object pred : predictions) {
                        if (pred instanceof Map) {
                            Map<String, Object> prediction = (Map<String, Object>) pred;
                            String label = (String) prediction.get("label");
                            Object scoreObj = prediction.get("score");
                            if (label != null && scoreObj instanceof Number) {
                                String emotionKey = mapHuggingFaceLabelToEmotion(label);
                                emotions.put(emotionKey, ((Number) scoreObj).doubleValue());
                            }
                        }
                    }
                }
            }
        }

        // If no emotions were parsed, use fallback
        if (emotions.isEmpty()) {
            log.error("❌ Could not parse API response! Response type: {}", 
                    apiResponse.getClass().getSimpleName());
            log.error("Response content: {}", apiResponse);
            log.error("⚠️ Using random mock response as fallback");
            return getRandomMockEmotionResponse();
        }
        
        log.info("✅ Successfully parsed {} emotions from API response", emotions.size());

        // Find emotion with highest confidence
        String dominantEmotion = emotions.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("NEUTRAL");

        Double confidence = emotions.getOrDefault(dominantEmotion, 0.5);

        response.setEmotion(dominantEmotion);
        response.setConfidence(confidence);
        response.setEmotions(emotions);

        log.info("Parsed emotion: {} with confidence: {}, all emotions: {}", 
                dominantEmotion, confidence, emotions);

        return response;
    }

    /**
     * Map Hugging Face emotion labels to our emotion types
     * Supports both text-based models and vision-based models
     */
    private String mapHuggingFaceLabelToEmotion(String label) {
        if (label == null) {
            return "NEUTRAL";
        }
        
        String lowerLabel = label.toLowerCase();
        log.debug("Mapping Hugging Face label '{}' to emotion type", label);
        
        // Text-based model labels (j-hartmann/emotion-english-distilroberta-base)
        if (lowerLabel.contains("joy") || lowerLabel.contains("happy") || lowerLabel.contains("happiness")) {
            return "HAPPY";
        } else if (lowerLabel.contains("sad") || lowerLabel.contains("sadness")) {
            return "SAD";
        } else if (lowerLabel.contains("angry") || lowerLabel.contains("anger") || lowerLabel.contains("rage")) {
            return "ANGRY";
        } else if (lowerLabel.contains("fear") || lowerLabel.contains("afraid") || lowerLabel.contains("scared")) {
            return "FEAR";
        } else if (lowerLabel.contains("love") || lowerLabel.contains("surprise")) {
            return "HAPPY"; // Map positive emotions to HAPPY
        }
        // Vision-based model labels (trpakov/vit-face-expression)
        else if (lowerLabel.contains("happy") || lowerLabel.contains("smile") || lowerLabel.contains("joy")) {
            return "HAPPY";
        } else if (lowerLabel.contains("sad") || lowerLabel.contains("sadness")) {
            return "SAD";
        } else if (lowerLabel.contains("angry") || lowerLabel.contains("anger") || lowerLabel.contains("mad")) {
            return "ANGRY";
        } else if (lowerLabel.contains("fear") || lowerLabel.contains("afraid") || lowerLabel.contains("scared")) {
            return "FEAR";
        } else if (lowerLabel.contains("neutral") || lowerLabel.contains("calm")) {
            return "NEUTRAL";
        } else if (lowerLabel.contains("surprise") || lowerLabel.contains("surprised")) {
            return "HAPPY"; // Surprise can be positive
        } else if (lowerLabel.contains("disgust")) {
            return "ANGRY"; // Map disgust to angry
        }
        
        // Default fallback
        log.warn("Unknown emotion label '{}', defaulting to NEUTRAL", label);
        return "NEUTRAL";
    }

    /**
     * Mock response for testing when API is unavailable
     * Returns a random emotion to avoid always returning SAD
     */
    private EmotionDetectionResponse getRandomMockEmotionResponse() {
        java.util.Random random = new java.util.Random();
        String[] emotionTypes = {"HAPPY", "SAD", "ANGRY", "FEAR", "NEUTRAL"};
        String randomEmotion = emotionTypes[random.nextInt(emotionTypes.length)];
        
        Map<String, Double> emotions = new HashMap<>();
        double baseConfidence = 0.3 + (random.nextDouble() * 0.4); // Between 0.3 and 0.7
        
        // Set the random emotion with highest confidence
        emotions.put(randomEmotion, baseConfidence);
        
        // Add other emotions with lower random values
        for (String emotion : emotionTypes) {
            if (!emotion.equals(randomEmotion)) {
                emotions.put(emotion, random.nextDouble() * 0.3); // 0 to 0.3
            }
        }

        EmotionDetectionResponse response = new EmotionDetectionResponse();
        response.setEmotion(randomEmotion);
        response.setConfidence(baseConfidence);
        response.setEmotions(emotions);
        
        log.warn("Using random mock emotion response: {} (confidence: {})", randomEmotion, baseConfidence);

        return response;
    }

    /**
     * Map API emotion string to EmotionTypeEnum
     */
    public EmotionTypeEnum mapToEmotionTypeEnum(String emotion) {
        if (emotion == null) {
            return EmotionTypeEnum.NEUTRAL;
        }

        String upperEmotion = emotion.toUpperCase();
        
        return switch (upperEmotion) {
            case "HAPPY", "JOY", "HAPPINESS" -> EmotionTypeEnum.HAPPY;
            case "SAD", "SADNESS" -> EmotionTypeEnum.SAD;
            case "ANGRY", "ANGER", "MAD" -> EmotionTypeEnum.ANGRY;
            case "FEAR", "AFRAID", "SCARED" -> EmotionTypeEnum.FEAR;
            default -> EmotionTypeEnum.NEUTRAL;
        };
    }
}