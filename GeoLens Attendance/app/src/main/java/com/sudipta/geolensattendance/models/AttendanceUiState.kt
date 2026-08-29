package com.sudipta.geolensattendance.models

data class AttendanceUiState(
    val officeLat: Double? = null,
    val officeLng: Double? = null,
    val currentDistance: Float? = null,
    val isMarkEnabled: Boolean = false,
    val isLoading: Boolean = false,
    val message: String? = null
)