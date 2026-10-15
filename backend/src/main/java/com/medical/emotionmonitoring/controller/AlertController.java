package com.medical.emotionmonitoring.controller;

import com.medical.emotionmonitoring.dto.AlertResponse;
import com.medical.emotionmonitoring.service.AlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/alerts")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AlertController {

    private final AlertService alertService;

    @GetMapping("/manager/{managerId}")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<List<AlertResponse>> getAlertsByManagerId(@PathVariable Long managerId) {
        try {
            List<AlertResponse> alerts = alertService.getAlertsByManagerId(managerId).stream()
                    .map(this::mapToAlertResponse)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(alerts);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/manager/{managerId}/unread")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<List<AlertResponse>> getUnreadAlertsByManagerId(@PathVariable Long managerId) {
        try {
            List<AlertResponse> alerts = alertService.getUnreadAlertsByManagerId(managerId).stream()
                    .map(this::mapToAlertResponse)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(alerts);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PutMapping("/{alertId}/read")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<?> markAlertAsRead(@PathVariable Long alertId) {
        try {
            alertService.markAsRead(alertId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    private AlertResponse mapToAlertResponse(com.medical.emotionmonitoring.entity.Alert alert) {
        AlertResponse response = new AlertResponse();
        response.setId(alert.getId());
        response.setMessage(alert.getMessage());
        response.setCreatedAt(alert.getCreatedAt());
        response.setIsRead(alert.getIsRead());
        response.setEmployeeId(alert.getEmployee().getId());
        response.setEmployeeName(alert.getEmployee().getFullName());
        response.setManagerId(alert.getManager().getId());
        response.setManagerName(alert.getManager().getFullName());
        return response;
    }
}

