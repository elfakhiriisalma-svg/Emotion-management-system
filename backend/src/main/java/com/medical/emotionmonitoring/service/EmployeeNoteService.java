package com.medical.emotionmonitoring.service;

import com.medical.emotionmonitoring.dto.EmployeeNoteRequest;
import com.medical.emotionmonitoring.dto.EmployeeNoteResponse;
import com.medical.emotionmonitoring.entity.EmployeeNote;
import com.medical.emotionmonitoring.entity.Role;
import com.medical.emotionmonitoring.entity.User;
import com.medical.emotionmonitoring.repository.EmployeeNoteRepository;
import com.medical.emotionmonitoring.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EmployeeNoteService {

    private final EmployeeNoteRepository employeeNoteRepository;
    private final UserRepository userRepository;

    @Transactional
    public EmployeeNoteResponse createNote(Long employeeId, Long managerId, EmployeeNoteRequest request) {
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

        EmployeeNote note = new EmployeeNote();
        note.setEmployee(employee);
        note.setManager(manager);
        note.setNote(request.getNote());

        EmployeeNote savedNote = employeeNoteRepository.save(note);
        return mapToResponse(savedNote);
    }

    public List<EmployeeNoteResponse> getNotesByEmployeeId(Long employeeId, Long currentUserId, Role currentUserRole) {
        // Authorization: Employees can only view their own notes, Managers can view any employee's notes
        if (currentUserRole == Role.EMPLOYEE && !employeeId.equals(currentUserId)) {
            throw new RuntimeException("Unauthorized: Employees can only view their own notes");
        }

        List<EmployeeNote> notes = employeeNoteRepository.findByEmployeeIdOrderByCreatedAtDesc(employeeId);
        return notes.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<EmployeeNoteResponse> getNotesByManagerId(Long managerId) {
        List<EmployeeNote> notes = employeeNoteRepository.findByManagerIdOrderByCreatedAtDesc(managerId);
        return notes.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public EmployeeNoteResponse updateNote(Long noteId, Long managerId, EmployeeNoteRequest request) {
        EmployeeNote note = employeeNoteRepository.findById(noteId)
                .orElseThrow(() -> new RuntimeException("Note not found"));

        // Only the manager who created the note can update it
        if (!note.getManager().getId().equals(managerId)) {
            throw new RuntimeException("Unauthorized: Only the manager who created the note can update it");
        }

        note.setNote(request.getNote());
        EmployeeNote updatedNote = employeeNoteRepository.save(note);
        return mapToResponse(updatedNote);
    }

    @Transactional
    public void deleteNote(Long noteId, Long managerId) {
        EmployeeNote note = employeeNoteRepository.findById(noteId)
                .orElseThrow(() -> new RuntimeException("Note not found"));

        // Only the manager who created the note can delete it
        if (!note.getManager().getId().equals(managerId)) {
            throw new RuntimeException("Unauthorized: Only the manager who created the note can delete it");
        }

        employeeNoteRepository.delete(note);
    }

    private EmployeeNoteResponse mapToResponse(EmployeeNote note) {
        EmployeeNoteResponse response = new EmployeeNoteResponse();
        response.setId(note.getId());
        response.setNote(note.getNote());
        response.setEmployeeId(note.getEmployee().getId());
        response.setEmployeeName(note.getEmployee().getFullName());
        response.setManagerId(note.getManager().getId());
        response.setManagerName(note.getManager().getFullName());
        response.setCreatedAt(note.getCreatedAt());
        response.setUpdatedAt(note.getUpdatedAt());
        return response;
    }
}


