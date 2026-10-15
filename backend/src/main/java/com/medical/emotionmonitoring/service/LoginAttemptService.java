package com.medical.emotionmonitoring.service;

import com.medical.emotionmonitoring.entity.LoginAttempt;
import com.medical.emotionmonitoring.entity.User;
import com.medical.emotionmonitoring.repository.LoginAttemptRepository;
import com.medical.emotionmonitoring.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class LoginAttemptService {

    private final LoginAttemptRepository loginAttemptRepository;
    private final UserRepository userRepository;

    @Value("${security.login.max-attempts:5}")
    private int maxAttempts;

    @Value("${security.login.lockout-duration-minutes:30}")
    private int lockoutDurationMinutes;

    /**
     * Record a failed login attempt
     */
    @Transactional
    public void recordFailedAttempt(String email) {
        LoginAttempt attempt = loginAttemptRepository.findByEmail(email)
                .orElse(new LoginAttempt());

        attempt.setEmail(email);
        attempt.setAttemptCount(attempt.getAttemptCount() + 1);
        attempt.setLastAttemptTime(LocalDateTime.now());

        // Lock account if max attempts reached
        if (attempt.getAttemptCount() >= maxAttempts) {
            attempt.setIsLocked(true);
            attempt.setLockedUntil(LocalDateTime.now().plusMinutes(lockoutDurationMinutes));
            
            // Also lock the user account
            userRepository.findByEmail(email).ifPresent(user -> {
                user.setIsAccountNonLocked(false);
                userRepository.save(user);
            });
            
            log.warn("Account locked for email: {} after {} failed attempts. Locked until: {}", 
                    email, attempt.getAttemptCount(), attempt.getLockedUntil());
        }

        loginAttemptRepository.save(attempt);
    }

    /**
     * Record a successful login attempt and reset the counter
     */
    @Transactional
    public void recordSuccessfulAttempt(String email) {
        loginAttemptRepository.findByEmail(email).ifPresent(attempt -> {
            attempt.setAttemptCount(0);
            attempt.setIsLocked(false);
            attempt.setLockedUntil(null);
            loginAttemptRepository.save(attempt);
        });

        // Unlock user account if it was locked
        userRepository.findByEmail(email).ifPresent(user -> {
            if (!user.getIsAccountNonLocked()) {
                user.setIsAccountNonLocked(true);
                userRepository.save(user);
                log.info("Account unlocked for email: {}", email);
            }
        });
    }

    /**
     * Check if account is locked
     */
    public boolean isAccountLocked(String email) {
        return loginAttemptRepository.findByEmail(email)
                .map(attempt -> {
                    // Check if lockout period has expired
                    if (attempt.getIsLocked() && attempt.getLockedUntil() != null) {
                        if (LocalDateTime.now().isAfter(attempt.getLockedUntil())) {
                            // Lockout expired, unlock account
                            attempt.setIsLocked(false);
                            attempt.setLockedUntil(null);
                            attempt.setAttemptCount(0);
                            loginAttemptRepository.save(attempt);
                            
                            userRepository.findByEmail(email).ifPresent(user -> {
                                user.setIsAccountNonLocked(true);
                                userRepository.save(user);
                            });
                            
                            return false;
                        }
                        return true;
                    }
                    return attempt.getIsLocked();
                })
                .orElse(false);
    }

    /**
     * Get remaining attempts before lockout
     */
    public int getRemainingAttempts(String email) {
        return loginAttemptRepository.findByEmail(email)
                .map(attempt -> Math.max(0, maxAttempts - attempt.getAttemptCount()))
                .orElse(maxAttempts);
    }

    /**
     * Get lockout expiration time
     */
    public LocalDateTime getLockoutUntil(String email) {
        return loginAttemptRepository.findByEmail(email)
                .map(LoginAttempt::getLockedUntil)
                .orElse(null);
    }
}


