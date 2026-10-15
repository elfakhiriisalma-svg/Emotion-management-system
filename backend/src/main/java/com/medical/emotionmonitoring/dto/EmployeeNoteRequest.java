package com.medical.emotionmonitoring.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmployeeNoteRequest {

    @NotBlank(message = "Note is required")
    @Size(max = 2000, message = "Note must be less than 2000 characters")
    private String note;
}


