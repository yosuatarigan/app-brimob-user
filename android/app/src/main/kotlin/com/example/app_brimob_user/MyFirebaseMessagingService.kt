// android/app/src/main/kotlin/com/example/app_brimob_user/MyFirebaseMessagingService.kt
package com.example.app_brimob_user

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.RingtoneManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        // Check if this is an emergency notification
        val isEmergency = remoteMessage.data["priority"] == "emergency" ||
                         remoteMessage.data["type"] == "urgent"
                         
        println("FCM Message received. Emergency: $isEmergency")
        
        if (isEmergency) {
            handleEmergencyNotification(remoteMessage)
        } else {
            handleNormalNotification(remoteMessage)
        }
    }
    
    private fun handleEmergencyNotification(remoteMessage: RemoteMessage) {
        println("Handling EMERGENCY notification")
        
        // Force audio context untuk emergency
        setEmergencyAudioContext()
        
        // Trigger emergency vibration
        triggerEmergencyVibration()
        
        // Show emergency notification dengan highest priority
        showEmergencyNotification(remoteMessage)
    }
    
    private fun handleNormalNotification(remoteMessage: RemoteMessage) {
        println("Handling normal notification")
        showNormalNotification(remoteMessage)
    }
    
    private fun setEmergencyAudioContext() {
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            
            // Set alarm volume to max (bypasses silent mode)
            val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxVolume, 0)
            
            println("Emergency audio context set")
        } catch (e: Exception) {
            println("Error setting emergency audio: ${e.message}")
        }
    }
    
    private fun triggerEmergencyVibration() {
        try {
            val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            
            if (vibrator.hasVibrator()) {
                val pattern = longArrayOf(0, 1000, 500, 1000, 500, 1000) // Strong pattern
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val vibrationEffect = VibrationEffect.createWaveform(pattern, -1)
                    vibrator.vibrate(vibrationEffect)
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(pattern, -1)
                }
                
                println("Emergency vibration triggered")
            }
        } catch (e: Exception) {
            println("Error triggering vibration: ${e.message}")
        }
    }
    
    private fun showEmergencyNotification(remoteMessage: RemoteMessage) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Create emergency channel if not exists
        createEmergencyChannel(notificationManager)
        
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("emergency_notification", true)
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_ONE_SHOT
            }
        )
        
        // Emergency sound URI
        val alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        
        val notificationBuilder = NotificationCompat.Builder(this, "emergency_channel")
            .setSmallIcon(android.R.drawable.ic_dialog_alert) // Use system emergency icon
            .setContentTitle(remoteMessage.notification?.title ?: "EMERGENCY ALERT")
            .setContentText(remoteMessage.notification?.body ?: "Emergency notification")
            .setAutoCancel(false) // Don't auto-cancel
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(pendingIntent)
            .setSound(alarmSound, AudioManager.STREAM_ALARM) // Use ALARM stream
            .setVibrate(longArrayOf(0, 1000, 500, 1000, 500, 1000))
            .setColor(android.graphics.Color.RED)
            .setColorized(true)
        
        notificationManager.notify(System.currentTimeMillis().toInt(), notificationBuilder.build())
        println("Emergency notification displayed")
    }
    
    private fun showNormalNotification(remoteMessage: RemoteMessage) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Create normal channel if not exists
        createNormalChannel(notificationManager)
        
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_ONE_SHOT
            }
        )
        
        val notificationBuilder = NotificationCompat.Builder(this, "normal_channel")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(remoteMessage.notification?.title ?: "Notification")
            .setContentText(remoteMessage.notification?.body ?: "")
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
        
        notificationManager.notify(
            remoteMessage.hashCode(),
            notificationBuilder.build()
        )
    }
    
    private fun createEmergencyChannel(notificationManager: NotificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "emergency_channel"
            val channelName = "Emergency Notifications"
            val importance = NotificationManager.IMPORTANCE_HIGH
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = "Critical emergency notifications"
                enableLights(true)
                lightColor = android.graphics.Color.RED
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 1000, 500, 1000, 500, 1000)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
                
                // Set emergency sound
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_ALARM) // ALARM usage bypasses silent
                    .build()
                
                val alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                setSound(alarmSound, audioAttributes)
            }
            
            notificationManager.createNotificationChannel(channel)
            println("Emergency notification channel created")
        }
    }
    
    private fun createNormalChannel(notificationManager: NotificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "normal_channel"
            val channelName = "Normal Notifications"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = "Normal notifications"
                enableLights(true)
                enableVibration(true)
            }
            
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        println("New FCM token: $token")
        // Send token to your server
    }
}