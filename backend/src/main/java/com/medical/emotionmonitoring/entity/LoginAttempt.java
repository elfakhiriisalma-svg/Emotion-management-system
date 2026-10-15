package com.medical.emotionmonitoring.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "login_attempts")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String email;

    @Column(name = "attempt_count")
    private Integer attemptCount = 0;

    @Column(name = "last_attempt_time")
    private LocalDateTime lastAttemptTime;

    @Column(name = "is_locked")
    private Boolean isLocked = false;

    @Column(name = "locked_until")
    private LocalDateTime lockedUntil;

    @PrePersist
    protected void onCreate() {
        if (lastAttemptTime == null) {
            lastAttemptTime = LocalDateTime.now();
        }
    }
}


