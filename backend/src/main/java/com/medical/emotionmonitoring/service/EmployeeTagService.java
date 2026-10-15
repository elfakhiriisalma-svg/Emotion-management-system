package com.medical.emotionmonitoring.service;

import com.medical.emotionmonitoring.dto.EmployeeTagRequest;
import com.medical.emotionmonitoring.dto.EmployeeTagResponse;
import com.medical.emotionmonitoring.entity.EmployeeTag;
import com.medical.emotionmonitoring.entity.Role;
import com.medical.emotionmonitoring.entity.User;
import com.medical.emotionmonitoring.repository.EmployeeTagRepository;
import com.medical.emotionmonitoring.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EmployeeTagService {

    private final EmployeeTagRepository employeeTagRepository;
    private final UserRepository userRepository;

    @Transactional
    public EmployeeTagResponse addTag(Long employeeId, Long managerId, EmployeeTagRequest request) {
        User employee = userRepository.findById(employeeId)
                .orElseThrow(() -> new RuntimeException("Employee not found"));
        
        if (employee.getRole() != Role.EMPLOYEE) {
            throw new RuntimeException("User is not a employee");
        }

        User manager = userRepository.findById(managerId)
                .orElseThrow(() -> new RuntimeException("Manager not found"));
        
        if (manager.getRole() != Role.MANAGER) {
            throw new RuntimeException("User is not a manager");
        }

        // Check if tag already exists
        employeeTagRepository.findByEmployeeIdAndManagerIdAndTag(employeeId, managerId, request.getTag())
                .ifPresent(tag -> {
                    throw new RuntimeException("Tag already exists for this employee");
                });

        EmployeeTag tag = new EmployeeTag();
        tag.setEmployee(employee);
        tag.setManager(manager);
        tag.setTag(request.getTag());

        EmployeeTag savedTag = employeeTagRepository.save(tag);
        return mapToResponse(savedTag);
    }

    public List<EmployeeTagResponse> getTagsByEmployeeId(Long employeeId) {
        List<EmployeeTag> tags = employeeTagRepository.findByEmployeeId(employeeId);
        return tags.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<EmployeeTagResponse> getTagsByEmployeeIdAndManagerId(Long employeeId, Long managerId) {
        List<EmployeeTag> tags = employeeTagRepository.findByEmployeeIdAndManagerId(employeeId, managerId);
        return tags.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public void removeTag(Long employeeId, Long managerId, String tag) {
        EmployeeTag employeeTag = employeeTagRepository
                .findByEmployeeIdAndManagerIdAndTag(employeeId, managerId, tag)
                .orElseThrow(() -> new RuntimeException("Tag not found"));

        // Only the manager who created the tag can remove it
        if (!employeeTag.getManager().getId().equals(managerId)) {
            throw new RuntimeException("Unauthorized: Only the manager who created the tag can remove it");
        }

        employeeTagRepository.delete(employeeTag);
    }

    @Transactional
    public void removeTagById(Long tagId, Long managerId) {
        EmployeeTag tag = employeeTagRepository.findById(tagId)
                .orElseThrow(() -> new RuntimeException("Tag not found"));

        // Only the manager who created the tag can remove it
        if (!tag.getManager().getId().equals(managerId)) {
            throw new RuntimeException("Unauthorized: Only the manager who created the tag can remove it");
        }

        employeeTagRepository.delete(tag);
    }

    private EmployeeTagResponse mapToResponse(EmployeeTag tag) {
        EmployeeTagResponse response = new EmployeeTagResponse();
        response.setId(tag.getId());
        response.setTag(tag.getTag());
        response.setEmployeeId(tag.getEmployee().getId());
        response.setEmployeeName(tag.getEmployee().getFullName());
        response.setManagerId(tag.getManager().getId());
        response.setManagerName(tag.getManager().getFullName());
        response.setCreatedAt(tag.getCreatedAt());
        response.setUpdatedAt(tag.getUpdatedAt());
        return response;
    }
}


