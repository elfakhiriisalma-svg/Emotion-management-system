package com.medical.emotionmonitoring.controller;

import com.medical.emotionmonitoring.dto.UserResponse;
import com.medical.emotionmonitoring.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long id) {
        try {
            UserResponse response = userService.getUserById(id);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<UserResponse> getUserByEmail(@PathVariable String email) {
        try {
            UserResponse response = userService.getUserByEmail(email);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @GetMapping
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        try {
            List<UserResponse> responses = userService.getAllUsers();
            return ResponseEntity.ok(responses);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/employees")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<List<UserResponse>> getEmployees() {
        try {
            List<UserResponse> responses = userService.getEmployees();
            return ResponseEntity.ok(responses);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser() {
        try {
            // Get current authenticated user
            org.springframework.security.core.Authentication authentication = 
                    org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
            
            String email = authentication.getName();
            UserResponse response = userService.getUserByEmail(email);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PutMapping("/me")
    public ResponseEntity<?> updateCurrentUser(@Valid @RequestBody com.medical.emotionmonitoring.dto.UpdateProfileRequest request) {
        try {
            org.springframework.security.core.Authentication authentication = 
                    org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
            
            String email = authentication.getName();
            UserResponse response = userService.updateUserProfile(email, request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse("An error occurred while updating profile"));
        }
    }

    @PutMapping("/me/password")
    public ResponseEntity<?> changePassword(@Valid @RequestBody com.medical.emotionmonitoring.dto.ChangePasswordRequest request) {
        try {
            org.springframework.security.core.Authentication authentication = 
                    org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
            
            String email = authentication.getName();
            userService.changePassword(email, request.getCurrentPassword(), request.getNewPassword());
            return ResponseEntity.ok(new java.util.HashMap<String, String>() {{
                put("message", "Password changed successfully");
            }});
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse("An error occurred while changing password"));
        }
    }

    @PostMapping("/managers/{managerId}/assign-employee/{employeeId}")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<?> assignEmployeeToManager(
            @PathVariable Long managerId,
            @PathVariable Long employeeId) {
        try {
            userService.assignEmployeeToManager(managerId, employeeId);
            return ResponseEntity.ok(new java.util.HashMap<String, String>() {{
                put("message", "Employee assigned successfully");
            }});
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse("An error occurred while assigning employee"));
        }
    }

    @DeleteMapping("/managers/{managerId}/unassign-employee/{employeeId}")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<?> unassignEmployeeFromManager(
            @PathVariable Long managerId,
            @PathVariable Long employeeId) {
        try {
            userService.unassignEmployeeFromManager(managerId, employeeId);
            return ResponseEntity.ok(new java.util.HashMap<String, String>() {{
                put("message", "Employee unassigned successfully");
            }});
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse("An error occurred while unassigning employee"));
        }
    }

    @PutMapping("/employees/{employeeId}")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<?> updateEmployeeInfo(
            @PathVariable Long employeeId,
            @Valid @RequestBody com.medical.emotionmonitoring.dto.UpdateEmployeeRequest request) {
        try {
            org.springframework.security.core.Authentication authentication = 
                    org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
            
            String email = authentication.getName();
            com.medical.emotionmonitoring.dto.UserResponse currentUser = userService.getUserByEmail(email);
            Long managerId = currentUser.getId();
            
            com.medical.emotionmonitoring.dto.UserResponse response = 
                    userService.updateEmployeeInfo(employeeId, managerId, request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new com.medical.emotionmonitoring.dto.ErrorResponse("An error occurred while updating employee information"));
        }
    }
}
