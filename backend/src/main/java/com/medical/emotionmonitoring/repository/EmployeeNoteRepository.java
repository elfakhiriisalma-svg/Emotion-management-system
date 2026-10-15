package com.medical.emotionmonitoring.repository;

import com.medical.emotionmonitoring.entity.EmployeeNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EmployeeNoteRepository extends JpaRepository<EmployeeNote, Long> {
    List<EmployeeNote> findByEmployeeIdOrderByCreatedAtDesc(Long employeeId);
    List<EmployeeNote> findByManagerIdOrderByCreatedAtDesc(Long managerId);
    List<EmployeeNote> findByEmployeeIdAndManagerIdOrderByCreatedAtDesc(Long employeeId, Long managerId);
}


