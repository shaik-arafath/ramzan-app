package com.example.ramzan_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class AdhanService : Service() {

    private var mediaPlayer: MediaPlayer? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == "STOP") {
            stopSelf()
            return START_NOT_STICKY
        }

        val type = intent?.getStringExtra("TYPE") ?: "ADHAN" // or "SIREN"

        startInForeground(type)

        val resId = if (type == "SIREN") R.raw.siren else R.raw.azan
        mediaPlayer = MediaPlayer.create(this, resId)
        mediaPlayer?.isLooping = false
        mediaPlayer?.setOnCompletionListener {
            stopSelf()
        }
        mediaPlayer?.start()

        return START_NOT_STICKY
    }

    private fun startInForeground(type: String) {
        val channelId = "adhan_channel"
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Adhan & Siren",
                NotificationManager.IMPORTANCE_HIGH
            )
            nm.createNotificationChannel(channel)
        }

        // STOP action
        val stopIntent = Intent(this, AdhanService::class.java).apply {
            action = "STOP"
        }
        val stopPending = PendingIntent.getService(
            this,
            0,
            stopIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle(if (type == "SIREN") "Siren" else "Adhan")
            .setContentText("Tap STOP to stop the sound")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .addAction(0, "STOP", stopPending)
            .build()

        startForeground(1, notification)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
        super.onDestroy()
    }
}
