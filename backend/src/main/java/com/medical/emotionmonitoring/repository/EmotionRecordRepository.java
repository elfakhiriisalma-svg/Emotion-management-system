package com.medical.emotionmonitoring.repository;

import com.medical.emotionmonitoring.entity.EmotionRecord;
import com.medical.emotionmonitoring.entity.EmotionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EmotionRecordRepository extends JpaRepository<EmotionRecord, Long> {
    List<EmotionRecord> findByUserId(Long userId);
    List<EmotionRecord> findByUserIdOrderByRecordedAtDesc(Long userId);
    List<EmotionRecord> findByUserIdAndEmotionType(Long userId, EmotionType emotionType);
    
    @Query("SELECT e FROM EmotionRecord e WHERE e.user.id = :userId AND e.recordedAt BETWEEN :startDate AND :endDate ORDER BY e.recordedAt DESC")
    List<EmotionRecord> findByUserIdAndDateRange(
        @Param("userId") Long userId,
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );
    
    @Query("SELECT COUNT(e) FROM EmotionRecord e WHERE e.user.id = :userId AND e.emotionType = :emotionType")
    Long countByUserIdAndEmotionType(@Param("userId") Long userId, @Param("emotionType") EmotionType emotionType);
}

