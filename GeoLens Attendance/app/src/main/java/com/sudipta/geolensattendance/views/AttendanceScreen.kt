package com.sudipta.geolensattendance.views

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.sudipta.geolensattendance.ui.theme.GeoLensAttendanceTheme

@Composable
fun AttendanceScreen(modifier: Modifier = Modifier) {
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(scrollState)
            .padding(16.dp)
    ) {
        OfficeContextScreen()

        DistanceStatusScreen(modifier = modifier, distance = 120)

        MarkAttendanceScreen(modifier = modifier, onClick = null)
    }
}

@Preview(showBackground = true)
@Composable
fun AttendanceScreenPreview() {
    GeoLensAttendanceTheme {
        AttendanceScreen()
    }
}
