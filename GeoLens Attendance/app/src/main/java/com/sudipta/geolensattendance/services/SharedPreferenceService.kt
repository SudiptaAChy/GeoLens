package com.sudipta.geolensattendance.services

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit

class SharedPreferenceService(context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun saveOfficeLocation(lat: Double, lng: Double) {
        prefs.edit {
            putFloat(KEY_LAT, lat.toFloat())
                .putFloat(KEY_LNG, lng.toFloat())
        }
    }

    fun getOfficeLocation(): Pair<Double, Double>? {
        val lat = prefs.getFloat(KEY_LAT, Float.MIN_VALUE)
        val lng = prefs.getFloat(KEY_LNG, Float.MIN_VALUE)
        return if (lat != Float.MIN_VALUE && lng != Float.MIN_VALUE) {
            lat.toDouble() to lng.toDouble()
        } else null
    }

    fun clearOfficeLocation() {
        prefs.edit { remove(KEY_LAT).remove(KEY_LNG) }
    }

    companion object {
        private const val PREFS_NAME = "geolens_prefs"
        private const val KEY_LAT = "office_lat"
        private const val KEY_LNG = "office_lng"
    }
}