package com.medical.emotionmonitoring.service;

import com.medical.emotionmonitoring.entity.Alert;
import com.medical.emotionmonitoring.entity.Role;
import com.medical.emotionmonitoring.entity.User;
import com.medical.emotionmonitoring.repository.AlertRepository;
import com.medical.emotionmonitoring.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AlertService {

    private final AlertRepository alertRepository;
    private final UserRepository userRepository;

    @Transactional
    public Alert createAlert(Long employeeId, String message) {
        User employee = userRepository.findById(employeeId)
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        // Find the manager assigned to this employee, or an available manager
        User manager = findManagerForEmployee(employee)
                .orElseThrow(() -> new RuntimeException(
                        "No manager available in the system. Please create a manager user first."));

        // Check if similar alert already exists (avoid duplicates)
        Alert alert = new Alert();
        alert.setMessage(message);
        alert.setEmployee(employee);
        alert.setManager(manager);
        alert.setIsRead(false);

        return alertRepository.save(alert);
    }

    /**
     * Find the manager assigned to a employee, or an available manager if none is assigned
     */
    private Optional<User> findManagerForEmployee(User employee) {
        // First, try to find a manager assigned to this employee
        List<User> managers = userRepository.findAll().stream()
                .filter(user -> user.getRole() == Role.MANAGER)
                .toList();

        for (User manager : managers) {
            if (manager.getAssignedEmployees() != null 
                    && manager.getAssignedEmployees().contains(employee)) {
                return Optional.of(manager);
            }
        }

        // If no assigned manager found, return the first available manager
        if (managers.isEmpty()) {
            return Optional.empty();
        }

        return Optional.of(managers.get(0));
    }

    /**
     * Find an available manager (for backward compatibility)
     * In a production system, this would use a manager-employee assignment table
     */
    private Optional<User> findAvailableManager() {
        List<User> managers = userRepository.findAll().stream()
                .filter(user -> user.getRole() == Role.MANAGER)
                .toList();

        if (managers.isEmpty()) {
            return Optional.empty();
        }

        // Return the first available manager
        // In a real system, you might implement load balancing or assignment logic
        return Optional.of(managers.get(0));
    }

    public List<Alert> getAlertsByManagerId(Long managerId) {
        return alertRepository.findByManagerIdOrderByCreatedAtDesc(managerId);
    }

    public List<Alert> getAlertsByEmployeeId(Long employeeId) {
        return alertRepository.findByEmployeeIdOrderByCreatedAtDesc(employeeId);
    }

    public List<Alert> getUnreadAlertsByManagerId(Long managerId) {
        return alertRepository.findUnreadAlertsByManagerId(managerId);
    }

    public void markAsRead(Long alertId) {
        Alert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new RuntimeException("Alert not found"));
        alert.setIsRead(true);
        alertRepository.save(alert);
    }
}

