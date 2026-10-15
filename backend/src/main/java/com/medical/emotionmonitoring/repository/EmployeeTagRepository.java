package com.medical.emotionmonitoring.repository;

import com.medical.emotionmonitoring.entity.EmployeeTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeTagRepository extends JpaRepository<EmployeeTag, Long> {
    List<EmployeeTag> findByEmployeeId(Long employeeId);
    List<EmployeeTag> findByEmployeeIdAndManagerId(Long employeeId, Long managerId);
    Optional<EmployeeTag> findByEmployeeIdAndManagerIdAndTag(Long employeeId, Long managerId, String tag);
    void deleteByEmployeeIdAndManagerIdAndTag(Long employeeId, Long managerId, String tag);
}


