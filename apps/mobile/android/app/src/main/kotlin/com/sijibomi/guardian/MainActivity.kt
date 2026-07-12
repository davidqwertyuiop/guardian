package com.sijibomi.guardian

import android.content.Context
import android.os.Build
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "guardian/radio_type")
            .setMethodCallHandler { call, result ->
                if (call.method == "mobileRadioType") {
                    result.success(mobileRadioType())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun mobileRadioType(): String {
        val telephony = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                when (telephony.dataNetworkType) {
                    TelephonyManager.NETWORK_TYPE_NR -> "5G"
                    TelephonyManager.NETWORK_TYPE_LTE,
                    19 -> "LTE"
                    TelephonyManager.NETWORK_TYPE_HSPAP,
                    TelephonyManager.NETWORK_TYPE_HSPA,
                    TelephonyManager.NETWORK_TYPE_HSDPA,
                    TelephonyManager.NETWORK_TYPE_HSUPA -> "3G"
                    TelephonyManager.NETWORK_TYPE_EDGE,
                    TelephonyManager.NETWORK_TYPE_GPRS -> "2G"
                    else -> "Cellular"
                }
            } else {
                when (telephony.networkType) {
                    TelephonyManager.NETWORK_TYPE_LTE -> "LTE"
                    TelephonyManager.NETWORK_TYPE_HSPAP,
                    TelephonyManager.NETWORK_TYPE_HSPA,
                    TelephonyManager.NETWORK_TYPE_HSDPA,
                    TelephonyManager.NETWORK_TYPE_HSUPA -> "3G"
                    TelephonyManager.NETWORK_TYPE_EDGE,
                    TelephonyManager.NETWORK_TYPE_GPRS -> "2G"
                    else -> "Cellular"
                }
            }
        } catch (_: SecurityException) {
            "Cellular"
        } catch (_: Exception) {
            "Cellular"
        }
    }
}
