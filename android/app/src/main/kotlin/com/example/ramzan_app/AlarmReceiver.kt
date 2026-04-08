package com.example.ramzan_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val type = intent.getStringExtra("TYPE") ?: "ADHAN"
        val serviceIntent = Intent(context, AdhanService::class.java).apply {
            putExtra("TYPE", type)
        }
        context.startForegroundService(serviceIntent)
    }
}
