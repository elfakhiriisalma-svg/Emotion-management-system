package com.medical.emotionmonitoring.service;

import com.medical.emotionmonitoring.dto.AuthResponse;
import com.medical.emotionmonitoring.dto.LoginRequest;
import com.medical.emotionmonitoring.dto.RegisterRequest;
import com.medical.emotionmonitoring.entity.User;
import com.medical.emotionmonitoring.repository.UserRepository;
import com.medical.emotionmonitoring.service.LoginAttemptService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserService userService;
    private final LoginAttemptService loginAttemptService;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        userService.register(request);
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found after registration"));

        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("userId", user.getId());
        extraClaims.put("role", user.getRole().name());

        String token = jwtService.generateToken(user, extraClaims);

        return new AuthResponse(
                token,
                "Bearer",
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getRole().name()
        );
    }

    public AuthResponse login(LoginRequest request) {
        String email = request.getEmail();
        
        // Check if account is locked
        if (loginAttemptService.isAccountLocked(email)) {
            log.warn("Login attempt blocked for locked account: {}", email);
            throw new RuntimeException("Account is locked due to too many failed login attempts. " +
                    "Please try again later or contact support.");
        }

        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            email,
                            request.getPassword()
                    )
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);

            // Record successful login
            loginAttemptService.recordSuccessfulAttempt(email);

            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            // Update last connected date
            user.setLastConnectedDate(LocalDateTime.now());
            userRepository.save(user);

            Map<String, Object> extraClaims = new HashMap<>();
            extraClaims.put("userId", user.getId());
            extraClaims.put("role", user.getRole().name());

            String token = jwtService.generateToken(user, extraClaims);

            log.info("Successful login for user: {}", email);

            return new AuthResponse(
                    token,
                    "Bearer",
                    user.getId(),
                    user.getFullName(),
                    user.getEmail(),
                    user.getRole().name()
            );
        } catch (AuthenticationException e) {
            // Record failed login attempt
            loginAttemptService.recordFailedAttempt(email);
            
            int remainingAttempts = loginAttemptService.getRemainingAttempts(email);
            log.warn("Failed login attempt for user: {}. Remaining attempts: {}", email, remainingAttempts);
            
            if (loginAttemptService.isAccountLocked(email)) {
                throw new RuntimeException("Account has been locked due to too many failed login attempts. " +
                        "Please try again later or contact support.");
            }
            
            throw new RuntimeException("Invalid email or password. " + remainingAttempts + " attempt(s) remaining.");
        }
    }
}

