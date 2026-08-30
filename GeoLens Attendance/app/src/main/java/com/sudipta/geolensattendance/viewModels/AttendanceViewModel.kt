package com.sudipta.geolensattendance.viewModels

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.sudipta.geolensattendance.models.AttendanceUiState
import com.sudipta.geolensattendance.services.GpsLocationService
import com.sudipta.geolensattendance.services.SharedPreferenceService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AttendanceViewModel @Inject constructor(
    private val locationService: GpsLocationService,
    private val prefsService: SharedPreferenceService
) : ViewModel() {

    private val _uiState = MutableStateFlow(AttendanceUiState())
    val uiState: StateFlow<AttendanceUiState> = _uiState.asStateFlow()

    private var locationJob: Job? = null

    init {
        loadOfficeLocation()
    }

    private fun loadOfficeLocation() {
        prefsService.getOfficeLocation()?.let { (lat, lng) ->
            _uiState.value = _uiState.value.copy(officeLat = lat, officeLng = lng)
        }
    }

    fun setOfficeLocation() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, message = null)

            val location = locationService.getCurrentLocation()

            Log.d("Location", "Office location = $location")

            if (location == null) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    message = "Unable to fetch GPS location. Check GPS/permissions."
                )
                return@launch
            }

            prefsService.saveOfficeLocation(location.latitude, location.longitude)

            _uiState.value = _uiState.value.copy(
                officeLat = location.latitude,
                officeLng = location.longitude,
                isLoading = false,
                message = "Office location saved."
            )
        }
    }

    fun startObservingLocation() {
        locationJob?.cancel()
        locationJob = viewModelScope.launch {
            locationService.getLocationUpdates().collect { location ->
                Log.d("Location", "User location = $location")
                val officeLat = _uiState.value.officeLat
                val officeLng = _uiState.value.officeLng

                if (officeLat != null && officeLng != null) {
                    val distance = locationService.distanceBetween(
                        location.latitude, location.longitude,
                        officeLat, officeLng
                    )
                    _uiState.value = _uiState.value.copy(
                        currentDistance = distance,
                        isMarkEnabled = distance <= RADIUS_METERS
                    )
                }
            }
        }
    }

    fun markAttendance() {
        val distance = _uiState.value.currentDistance
        if (distance != null && distance <= RADIUS_METERS) {
            _uiState.value = _uiState.value.copy(
                isMarkEnabled = false,
                message = "Attendance marked successfully!"
            )
        } else {
            _uiState.value = _uiState.value.copy(message = "You are out of range.")
        }
    }

    companion object {
        private const val RADIUS_METERS = 50f
    }
}