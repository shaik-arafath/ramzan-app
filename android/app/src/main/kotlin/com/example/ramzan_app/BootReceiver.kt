package com.example.ramzan_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // TODO: Optionally re-schedule alarms after reboot by
            // reading stored times from SharedPreferences and calling
            // the same scheduling logic used from Flutter.
        }
    }
}
