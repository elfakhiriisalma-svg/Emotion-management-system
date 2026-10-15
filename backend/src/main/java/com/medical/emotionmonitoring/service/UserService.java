package com.medical.emotionmonitoring.service;

import com.medical.emotionmonitoring.dto.RegisterRequest;
import com.medical.emotionmonitoring.dto.UserResponse;
import com.medical.emotionmonitoring.entity.Role;
import com.medical.emotionmonitoring.entity.User;
import com.medical.emotionmonitoring.exception.BusinessException;
import com.medical.emotionmonitoring.exception.EntityNotFoundException;
import com.medical.emotionmonitoring.exception.ValidationException;
import com.medical.emotionmonitoring.repository.UserRepository;
import com.medical.emotionmonitoring.validation.PasswordValidator;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public UserResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessException("Email already exists");
        }

        // Validate password strength
        PasswordValidator.ValidationResult passwordValidation = PasswordValidator.validate(request.getPassword());
        if (!passwordValidation.isValid()) {
            throw new ValidationException(passwordValidation.getMessage());
        }

        User user = new User();
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole() != null ? request.getRole() : Role.EMPLOYEE);

        User savedUser = userRepository.save(user);
        return mapToUserResponse(savedUser);
    }

    public UserResponse getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("User not found with id: " + id));
        return mapToUserResponse(user);
    }

    public UserResponse getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("User not found with email: " + email));
        return mapToUserResponse(user);
    }

    public List<UserResponse> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::mapToUserResponse)
                .collect(Collectors.toList());
    }

    public List<UserResponse> getEmployees() {
        return userRepository.findAll().stream()
                .filter(user -> user.getRole() == Role.EMPLOYEE)
                .map(this::mapToUserResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public UserResponse updateUserProfile(String email, com.medical.emotionmonitoring.dto.UpdateProfileRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("User not found with email: " + email));

        // Check if email is being changed and if it's already taken
        if (!user.getEmail().equals(request.getEmail())) {
            if (userRepository.existsByEmail(request.getEmail())) {
                throw new BusinessException("Email already exists");
            }
        }

        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());

        // Update employee profile fields
        if (user.getRole() == Role.EMPLOYEE) {
            user.setAge(request.getAge());
            user.setGender(request.getGender());
            user.setProfilePicture(request.getProfilePicture());
        }

        // Update manager profile fields
        if (user.getRole() == Role.MANAGER) {
            user.setSpecialty(request.getSpecialty());
        }

        User updatedUser = userRepository.save(user);
        return mapToUserResponse(updatedUser);
    }

    @Transactional
    public void changePassword(String email, String currentPassword, String newPassword) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("User not found with email: " + email));

        // Verify current password
        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new BusinessException("Current password is incorrect");
        }

        // Validate new password strength
        PasswordValidator.ValidationResult passwordValidation = PasswordValidator.validate(newPassword);
        if (!passwordValidation.isValid()) {
            throw new ValidationException(passwordValidation.getMessage());
        }

        // Update password
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    @Transactional
    public void assignEmployeeToManager(Long managerId, Long employeeId) {
        User manager = userRepository.findById(managerId)
                .orElseThrow(() -> new EntityNotFoundException("Manager not found with id: " + managerId));
        
        if (manager.getRole() != Role.MANAGER) {
            throw new BusinessException("User is not a manager");
        }

        User employee = userRepository.findById(employeeId)
                .orElseThrow(() -> new EntityNotFoundException("Employee not found with id: " + employeeId));
        
        if (employee.getRole() != Role.EMPLOYEE) {
            throw new BusinessException("User is not a employee");
        }

        if (manager.getAssignedEmployees() == null) {
            manager.setAssignedEmployees(new java.util.ArrayList<>());
        }

        if (!manager.getAssignedEmployees().contains(employee)) {
            manager.getAssignedEmployees().add(employee);
            userRepository.save(manager);
        }
    }

    @Transactional
    public void unassignEmployeeFromManager(Long managerId, Long employeeId) {
        User manager = userRepository.findById(managerId)
                .orElseThrow(() -> new EntityNotFoundException("Manager not found with id: " + managerId));
        
        if (manager.getRole() != Role.MANAGER) {
            throw new BusinessException("User is not a manager");
        }

        if (manager.getAssignedEmployees() != null) {
            manager.getAssignedEmployees().removeIf(employee -> employee.getId().equals(employeeId));
            userRepository.save(manager);
        }
    }

    @Transactional
    public UserResponse updateEmployeeInfo(Long employeeId, Long managerId, 
                                         com.medical.emotionmonitoring.dto.UpdateEmployeeRequest request) {
        User employee = userRepository.findById(employeeId)
                .orElseThrow(() -> new EntityNotFoundException("Employee not found with id: " + employeeId));

        if (employee.getRole() != Role.EMPLOYEE) {
            throw new BusinessException("User is not a employee");
        }

        User manager = userRepository.findById(managerId)
                .orElseThrow(() -> new EntityNotFoundException("Manager not found with id: " + managerId));

        if (manager.getRole() != Role.MANAGER) {
            throw new BusinessException("User is not a manager");
        }

        // Check if email is already taken by another user
        if (!employee.getEmail().equals(request.getEmail())) {
            userRepository.findByEmail(request.getEmail()).ifPresent(existingUser -> {
                if (!existingUser.getId().equals(employeeId)) {
                    throw new BusinessException("Email already exists");
                }
            });
        }

        employee.setFullName(request.getFullName());
        employee.setEmail(request.getEmail());
        
        // Managers are not allowed to modify employee age and gender
        // These fields can only be set by the employee themselves during registration or profile update
        // Ignoring age and gender from request to prevent unauthorized modifications

        User updatedEmployee = userRepository.save(employee);
        return mapToUserResponse(updatedEmployee);
    }

    private UserResponse mapToUserResponse(User user) {
        UserResponse response = new UserResponse();
        response.setId(user.getId());
        response.setFullName(user.getFullName());
        response.setEmail(user.getEmail());
        response.setRole(user.getRole());
        response.setCreatedAt(user.getCreatedAt());

        // Employee profile fields
        response.setAge(user.getAge());
        response.setGender(user.getGender());
        response.setProfilePicture(user.getProfilePicture());
        response.setLastConnectedDate(user.getLastConnectedDate());

        // Manager profile fields
        response.setSpecialty(user.getSpecialty());
        if (user.getAssignedEmployees() != null) {
            response.setAssignedEmployeeIds(
                    user.getAssignedEmployees().stream()
                            .map(User::getId)
                            .collect(java.util.stream.Collectors.toList())
            );
            response.setAssignedEmployeesCount(user.getAssignedEmployees().size());
        } else {
            response.setAssignedEmployeesCount(0);
        }

        return response;
    }
}

