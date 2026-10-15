package com.medical.emotionmonitoring.controller;

import com.medical.emotionmonitoring.dto.ErrorResponse;
import com.medical.emotionmonitoring.dto.EmployeeTagRequest;
import com.medical.emotionmonitoring.dto.EmployeeTagResponse;
import com.medical.emotionmonitoring.service.EmployeeTagService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/employee-tags")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class EmployeeTagController {

    private final EmployeeTagService employeeTagService;
    private final com.medical.emotionmonitoring.repository.UserRepository userRepository;

    @PostMapping("/employee/{employeeId}")
    public ResponseEntity<?> addTag(
            @PathVariable Long employeeId,
            @Valid @RequestBody EmployeeTagRequest request) {
        try {
            Long managerId = getCurrentUserId();
            EmployeeTagResponse response = employeeTagService.addTag(employeeId, managerId, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("An error occurred while adding tag"));
        }
    }

    @GetMapping("/employee/{employeeId}")
    public ResponseEntity<?> getTagsByEmployeeId(@PathVariable Long employeeId) {
        try {
            List<EmployeeTagResponse> tags = employeeTagService.getTagsByEmployeeId(employeeId);
            return ResponseEntity.ok(tags);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("An error occurred while fetching tags"));
        }
    }

    @GetMapping("/employee/{employeeId}/manager/{managerId}")
    public ResponseEntity<?> getTagsByEmployeeIdAndManagerId(
            @PathVariable Long employeeId,
            @PathVariable Long managerId) {
        try {
            Long currentUserId = getCurrentUserId();
            
            // Only managers can view tags, and only their own tags
            if (!managerId.equals(currentUserId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("Unauthorized: You can only view your own tags"));
            }
            
            List<EmployeeTagResponse> tags = employeeTagService.getTagsByEmployeeIdAndManagerId(employeeId, managerId);
            return ResponseEntity.ok(tags);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("An error occurred while fetching tags"));
        }
    }

    @DeleteMapping("/employee/{employeeId}/tag/{tag}")
    public ResponseEntity<?> removeTag(
            @PathVariable Long employeeId,
            @PathVariable String tag) {
        try {
            Long managerId = getCurrentUserId();
            employeeTagService.removeTag(employeeId, managerId, tag);
            return ResponseEntity.ok(new java.util.HashMap<String, String>() {{
                put("message", "Tag removed successfully");
            }});
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("An error occurred while removing tag"));
        }
    }

    @DeleteMapping("/{tagId}")
    public ResponseEntity<?> removeTagById(@PathVariable Long tagId) {
        try {
            Long managerId = getCurrentUserId();
            employeeTagService.removeTagById(tagId, managerId);
            return ResponseEntity.ok(new java.util.HashMap<String, String>() {{
                put("message", "Tag removed successfully");
            }});
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("An error occurred while removing tag"));
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


