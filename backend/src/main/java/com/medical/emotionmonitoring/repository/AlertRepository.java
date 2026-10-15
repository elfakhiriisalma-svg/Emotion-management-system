package com.medical.emotionmonitoring.repository;

import com.medical.emotionmonitoring.entity.Alert;
import com.medical.emotionmonitoring.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AlertRepository extends JpaRepository<Alert, Long> {
    
    List<Alert> findByManager(User manager);
    
    List<Alert> findByEmployee(User employee);
    
    List<Alert> findByManagerId(Long managerId);
    
    List<Alert> findByEmployeeId(Long employeeId);
    
    List<Alert> findByManagerIdOrderByCreatedAtDesc(Long managerId);
    
    List<Alert> findByEmployeeIdOrderByCreatedAtDesc(Long employeeId);
    
    List<Alert> findByManagerIdAndIsReadFalse(Long managerId);
    
    List<Alert> findByEmployeeIdAndIsReadFalse(Long employeeId);
    
    @Query("SELECT a FROM Alert a WHERE a.manager.id = :managerId AND a.isRead = false ORDER BY a.createdAt DESC")
    List<Alert> findUnreadAlertsByManagerId(@Param("managerId") Long managerId);
    
    @Query("SELECT a FROM Alert a WHERE a.employee.id = :employeeId AND a.isRead = false ORDER BY a.createdAt DESC")
    List<Alert> findUnreadAlertsByEmployeeId(@Param("employeeId") Long employeeId);
    
    @Query("SELECT a FROM Alert a WHERE a.manager.id = :managerId AND a.createdAt BETWEEN :startDate AND :endDate ORDER BY a.createdAt DESC")
    List<Alert> findByManagerIdAndDateRange(
        @Param("managerId") Long managerId,
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );
    
    @Query("SELECT a FROM Alert a WHERE a.employee.id = :employeeId AND a.createdAt BETWEEN :startDate AND :endDate ORDER BY a.createdAt DESC")
    List<Alert> findByEmployeeIdAndDateRange(
        @Param("employeeId") Long employeeId,
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );
    
    @Query("SELECT COUNT(a) FROM Alert a WHERE a.manager.id = :managerId AND a.isRead = false")
    Long countUnreadAlertsByManagerId(@Param("managerId") Long managerId);
    
    @Query("SELECT COUNT(a) FROM Alert a WHERE a.employee.id = :employeeId AND a.isRead = false")
    Long countUnreadAlertsByEmployeeId(@Param("employeeId") Long employeeId);
}

