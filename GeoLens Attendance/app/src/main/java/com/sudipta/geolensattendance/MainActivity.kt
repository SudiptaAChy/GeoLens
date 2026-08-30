package com.sudipta.geolensattendance

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import com.sudipta.geolensattendance.services.GpsLocationService
import com.sudipta.geolensattendance.ui.theme.GeoLensAttendanceTheme
import com.sudipta.geolensattendance.ui.theme.lightBlue
import com.sudipta.geolensattendance.views.AttendanceScreen
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var locationService: GpsLocationService

    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            GeoLensAttendanceTheme {
                Scaffold(
                    modifier = Modifier.fillMaxSize(),
                    topBar = {
                        TopAppBar(
                            title = { Text("Attendance") },
                            colors = TopAppBarDefaults.topAppBarColors(
                                containerColor = lightBlue,
                                titleContentColor = Color.White
                            )
                        )
                    }
                ) { innerPadding ->
                    val context = LocalContext.current
                    val scope = rememberCoroutineScope()

                    var hasLocationPermission by remember {
                        mutableStateOf(
                            ContextCompat.checkSelfPermission(
                                context,
                                Manifest.permission.ACCESS_FINE_LOCATION
                            ) == PackageManager.PERMISSION_GRANTED
                        )
                    }

                    val settingsLauncher = rememberLauncherForActivityResult(
                        contract = ActivityResultContracts.StartIntentSenderForResult()
                    ) {}

                    val permissionLauncher = rememberLauncherForActivityResult(
                        contract = ActivityResultContracts.RequestMultiplePermissions()
                    ) { permissions ->
                        hasLocationPermission = permissions[Manifest.permission.ACCESS_FINE_LOCATION] == true

                        if (hasLocationPermission) {
                            scope.launch {
                                locationService.checkLocationSettings()?.let { intentSenderRequest ->
                                    settingsLauncher.launch(intentSenderRequest)
                                }
                            }
                        }
                    }

                    LaunchedEffect(Unit) {
                        if (!hasLocationPermission) {
                            permissionLauncher.launch(
                                arrayOf(
                                    Manifest.permission.ACCESS_FINE_LOCATION,
                                    Manifest.permission.ACCESS_COARSE_LOCATION
                                )
                            )
                        } else {
                            locationService.checkLocationSettings()?.let { intentSenderRequest ->
                                settingsLauncher.launch(intentSenderRequest)
                            }
                        }
                    }

                    AttendanceScreen(
                        modifier = Modifier.padding(innerPadding),
                        hasLocationPermission = hasLocationPermission
                    )
                }
            }
        }
    }
}