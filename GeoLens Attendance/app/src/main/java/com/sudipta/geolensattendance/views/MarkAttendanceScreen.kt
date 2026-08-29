package com.sudipta.geolensattendance.views

import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import com.sudipta.geolensattendance.ui.theme.GeoLensAttendanceTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material3.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.sudipta.geolensattendance.ui.theme.lightBlue

@Composable
fun MarkAttendanceScreen(
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)?
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .drawBehind {
                val strokeWidth = 1.dp.toPx()
                val dashWidth = 6.dp.toPx()
                val gapWidth = 6.dp.toPx()

                val pathEffect = PathEffect.dashPathEffect(
                    floatArrayOf(dashWidth, gapWidth),
                    0f
                )

                drawRoundRect(
                    color = Color.LightGray,
                    style = Stroke(
                        width = strokeWidth,
                        pathEffect = pathEffect
                    ),
                    cornerRadius = CornerRadius(12.dp.toPx())
                )
            }
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Icon(
            imageVector = Icons.Outlined.Lock,
            contentDescription = "Locked",
            modifier = Modifier.size(32.dp),
            tint = Color.Gray
        )

        Button(
            onClick = { onClick?.invoke() },
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp),
            shape = RoundedCornerShape(8.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = lightBlue,
                contentColor = Color.White
            ),
            enabled = (onClick != null)
        ) {
            Text(
                text = "Mark Attendance",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )
        }

        Text(
            text = "AVAILABLE 9:00 AM - 10:30 AM",
            style = MaterialTheme.typography.bodySmall,
            color = Color.Gray
        )
    }
}

@Preview(showBackground = true)
@Composable
fun MarkAttendanceScreenPreview() {
    GeoLensAttendanceTheme {
        MarkAttendanceScreen {}
    }
}