package com.sudipta.geolensattendance.views

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.sudipta.geolensattendance.ui.theme.GeoLensAttendanceTheme
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.ui.Alignment
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.sudipta.geolensattendance.ui.theme.borderGreen
import com.sudipta.geolensattendance.ui.theme.borderRed
import com.sudipta.geolensattendance.ui.theme.green
import com.sudipta.geolensattendance.ui.theme.lightGreen
import com.sudipta.geolensattendance.ui.theme.lightRed
import com.sudipta.geolensattendance.ui.theme.red

@Composable
fun DistanceStatusScreen(
    modifier: Modifier = Modifier,
    distance: Int,
) {
    val isInRange = distance <= 50

    val status = if (isInRange) {
        "IN RANGE"
    } else {
        "OUT OF RANGE"
    }

    val statusColor = if (isInRange) {
        green
    } else {
        red
    }

    val lightStatusColor = if (isInRange) {
        lightGreen
    } else {
        lightRed
    }

    val borderStatusColor = if (isInRange) {
        borderGreen
    } else {
        borderRed
    }

    Column(
        modifier = modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {

        Box(
            modifier = Modifier.size(150.dp),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator(
                progress = { distance / 360f },
                modifier = Modifier.fillMaxSize(),
                strokeWidth = 6.dp,
                strokeCap = StrokeCap.Butt,
                trackColor = Color.LightGray,
                color = statusColor
            )

            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = distance.toString(),
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black
                )

                Text(
                    text = "AWAY",
                    style = MaterialTheme.typography.labelMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.Gray
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Row(
            modifier = Modifier
                .background(
                    color = lightStatusColor,
                    shape = RoundedCornerShape(50)
                )
                .border(
                    width = 1.dp,
                    color = borderStatusColor,
                    shape = RoundedCornerShape(50)
                )
                .padding(
                    horizontal = 14.dp,
                    vertical = 7.dp
                ),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(7.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(7.dp)
                    .clip(CircleShape)
                    .background(statusColor)
            )

            Text(
                text = status,
                color = statusColor,
                style = MaterialTheme.typography.labelMedium,
                fontWeight = FontWeight.Bold
            )
        }

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = "Move within 50 meters of the designated office location to enable check-in.",
            modifier = Modifier.padding(horizontal = 16.dp),
            style = MaterialTheme.typography.bodySmall,
            color = Color.Gray,
            textAlign = TextAlign.Center
        )
    }
}

@Preview(showBackground = true)
@Composable
fun DistanceStatusScreenPreview() {
    GeoLensAttendanceTheme {
        DistanceStatusScreen(distance = 120)
    }
}
