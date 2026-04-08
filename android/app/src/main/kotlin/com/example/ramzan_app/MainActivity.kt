package com.example.ramzan_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.ramzan_app/adhan_scheduler"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarms" -> {
                    val args = call.arguments as Map<*, *>
                    scheduleAlarmsFromFlutter(args)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleAlarmsFromFlutter(args: Map<*, *>) {
        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        fun scheduleOne(id: Int, hour: Int, minute: Int, type: String) {
            val now = System.currentTimeMillis()
            val cal = Calendar.getInstance().apply {
                timeInMillis = now
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            // If the time for today has already passed, move it to tomorrow so
            // the alarm does not fire immediately when the app opens.
            if (cal.timeInMillis <= now) {
                cal.add(Calendar.DAY_OF_YEAR, 1)
            }

            val intent = Intent(this, AlarmReceiver::class.java).apply {
                putExtra("TYPE", type)
            }

            val pi = PendingIntent.getBroadcast(
                this,
                id,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )

            am.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                cal.timeInMillis,
                pi
            )
        }

        fun parseTime(str: String?): Pair<Int, Int>? {
            if (str == null) return null
            val cleaned = str.trim().lowercase()
            if (cleaned.isEmpty()) return null
            val isPm = cleaned.contains("pm")
            val isAm = cleaned.contains("am")
            var numeric = cleaned.replace("am", "").replace("pm", "").trim()
            if (numeric.isEmpty()) return null
            val parts = numeric.split(":")
            val h = parts[0].toIntOrNull() ?: return null
            val m = if (parts.size > 1) parts[1].toIntOrNull() ?: 0 else 0
            var hour = h
            if (isPm && hour < 12) hour += 12
            if (isAm && hour == 12) hour = 0
            return Pair(hour, m)
        }

        val sehri = parseTime(args["sehri"] as String?)
        val iftar = parseTime(args["iftar"] as String?)
        val fajr = parseTime(args["fajr"] as String?)
        val dhuhr = parseTime(args["dhuhr"] as String?)
        val asr = parseTime(args["asr"] as String?)
        val maghrib = parseTime(args["maghrib"] as String?)
        val isha = parseTime(args["isha"] as String?)

        sehri?.let { scheduleOne(1, it.first, it.second, "SIREN") }
        iftar?.let { scheduleOne(2, it.first, it.second, "SIREN") }
        fajr?.let { scheduleOne(3, it.first, it.second, "ADHAN") }
        dhuhr?.let { scheduleOne(4, it.first, it.second, "ADHAN") }
        asr?.let { scheduleOne(5, it.first, it.second, "ADHAN") }
        maghrib?.let { scheduleOne(6, it.first, it.second, "ADHAN") }
        isha?.let { scheduleOne(7, it.first, it.second, "ADHAN") }
    }
}
