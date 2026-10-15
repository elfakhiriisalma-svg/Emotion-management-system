package com.medical.emotionmonitoring.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmployeeTagRequest {

    @NotBlank(message = "Tag is required")
    @Size(max = 50, message = "Tag must be less than 50 characters")
    private String tag;
}


