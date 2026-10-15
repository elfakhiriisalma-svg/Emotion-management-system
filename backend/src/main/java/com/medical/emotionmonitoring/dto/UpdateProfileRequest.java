package com.medical.emotionmonitoring.dto;

import com.medical.emotionmonitoring.entity.Gender;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateProfileRequest {

    @NotBlank(message = "Full name is required")
    @Size(min = 2, max = 100, message = "Full name must be between 2 and 100 characters")
    private String fullName;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    // Employee profile fields
    @Min(value = 1, message = "Age must be at least 1")
    @Max(value = 150, message = "Age must be at most 150")
    private Integer age;

    private Gender gender;

    @Size(max = 1000, message = "Profile picture URL must be less than 1000 characters")
    private String profilePicture;

    // Manager profile fields
    @Size(max = 100, message = "Specialty must be less than 100 characters")
    private String specialty;
}

