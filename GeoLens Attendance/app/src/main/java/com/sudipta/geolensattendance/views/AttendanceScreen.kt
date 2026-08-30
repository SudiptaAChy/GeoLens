package com.sudipta.geolensattendance.views

import android.widget.Toast
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.android.gms.maps.model.LatLng
import com.sudipta.geolensattendance.ui.theme.GeoLensAttendanceTheme
import com.sudipta.geolensattendance.viewModels.AttendanceViewModel

@Composable
fun AttendanceScreen(
    modifier: Modifier = Modifier,
    hasLocationPermission: Boolean
) {
    val context = LocalContext.current
    val scrollState = rememberScrollState()
    val viewModel: AttendanceViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(hasLocationPermission) {
        if (hasLocationPermission) {
            viewModel.startObservingLocation()
        }
    }

    LaunchedEffect(uiState.message) {
        uiState.message?.let { message ->
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(scrollState)
            .padding(16.dp)
    ) {
        OfficeContextScreen(
            location = LatLng(uiState.officeLat ?: 0.0, uiState.officeLng ?: 0.0),
            onSetLocation = { viewModel.setOfficeLocation() }
        )

        DistanceStatusScreen(
            distance = uiState.currentDistance?.toInt() ?: 0
        )

        Spacer(modifier = Modifier.height(10.dp))

        MarkAttendanceScreen(enabled = uiState.isMarkEnabled) {
            if (uiState.isMarkEnabled) {
                viewModel.markAttendance()
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun AttendanceScreenPreview() {
    GeoLensAttendanceTheme {
        AttendanceScreen(hasLocationPermission = false)
    }
}
