package com.medical.emotionmonitoring.repository;

import com.medical.emotionmonitoring.entity.Emotion;
import com.medical.emotionmonitoring.entity.EmotionTypeEnum;
import com.medical.emotionmonitoring.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EmotionRepository extends JpaRepository<Emotion, Long> {
    
    List<Emotion> findByEmployee(User employee);
    
    List<Emotion> findByEmployeeId(Long employeeId);
    
    List<Emotion> findByEmployeeIdOrderByTimestampDesc(Long employeeId);
    
    List<Emotion> findByEmployeeIdAndEmotionType(Long employeeId, EmotionTypeEnum emotionType);
    
    @Query("SELECT e FROM Emotion e WHERE e.employee.id = :employeeId AND e.timestamp BETWEEN :startDate AND :endDate ORDER BY e.timestamp DESC")
    List<Emotion> findByEmployeeIdAndDateRange(
        @Param("employeeId") Long employeeId,
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );
    
    @Query("SELECT COUNT(e) FROM Emotion e WHERE e.employee.id = :employeeId AND e.emotionType = :emotionType")
    Long countByEmployeeIdAndEmotionType(@Param("employeeId") Long employeeId, @Param("emotionType") EmotionTypeEnum emotionType);
    
    @Query("SELECT e FROM Emotion e WHERE e.employee.id = :employeeId ORDER BY e.confidence DESC")
    List<Emotion> findByEmployeeIdOrderByConfidenceDesc(Long employeeId);
}

