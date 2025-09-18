// android/app/src/main/kotlin/com/example/app_brimob_user/MainActivity.kt
package com.example.app_brimob_user

import android.content.Context
import android.media.AudioManager
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val EMERGENCY_AUDIO_CHANNEL = "emergency_audio"
    private val EMERGENCY_VIBRATION_CHANNEL = "emergency_vibration"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup emergency audio channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EMERGENCY_AUDIO_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setEmergencyAudio" -> {
                        setEmergencyAudioContext()
                        result.success(true)
                    }
                    "playEmergencySound" -> {
                        playEmergencySound()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        
        // Setup emergency vibration channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EMERGENCY_VIBRATION_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "emergencyVibrate" -> {
                        triggerEmergencyVibration()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun setEmergencyAudioContext() {
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            
            // Set audio stream untuk emergency
            audioManager.setStreamVolume(
                AudioManager.STREAM_ALARM, // Gunakan ALARM stream (bypass silent mode)
                audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM),
                0
            )
            
            // Request audio focus dengan cara yang benar
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM) // CRITICAL: Usage ALARM
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
                
                // Simplified focus request untuk menghindari error
                val focusRequest = audioManager.requestAudioFocus(
                    null, // No listener needed for emergency
                    AudioManager.STREAM_ALARM,
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
                )
                
                println("Emergency audio context set. Focus result: $focusRequest")
            } else {
                @Suppress("DEPRECATION")
                val focusRequest = audioManager.requestAudioFocus(
                    null,
                    AudioManager.STREAM_ALARM,
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
                )
                println("Emergency audio context set (legacy). Focus result: $focusRequest")
            }
            
        } catch (e: Exception) {
            println("Error setting emergency audio context: ${e.message}")
        }
    }
    
    private fun playEmergencySound() {
        try {
            val mediaPlayer = MediaPlayer()
            
            // Set audio attributes untuk emergency
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM) // BYPASS silent mode
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
                
                mediaPlayer.setAudioAttributes(audioAttributes)
            } else {
                @Suppress("DEPRECATION")
                mediaPlayer.setAudioStreamType(AudioManager.STREAM_ALARM)
            }
            
            // Load emergency sound dari assets
            val assetFileDescriptor = assets.openFd("sounds/emergency_alert.mp3")
            mediaPlayer.setDataSource(
                assetFileDescriptor.fileDescriptor,
                assetFileDescriptor.startOffset,
                assetFileDescriptor.length
            )
            
            mediaPlayer.prepareAsync()
            mediaPlayer.setOnPreparedListener { player ->
                player.start()
                println("Emergency sound started playing")
            }
            
            mediaPlayer.setOnCompletionListener { player ->
                player.release()
                println("Emergency sound completed")
            }
            
            mediaPlayer.setOnErrorListener { player, what, extra ->
                println("MediaPlayer error: what=$what, extra=$extra")
                player.release()
                true
            }
            
        } catch (e: Exception) {
            println("Error playing emergency sound: ${e.message}")
        }
    }
    
    private fun triggerEmergencyVibration() {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            
            if (vibrator.hasVibrator()) {
                // Pattern: delay, vibrate, delay, vibrate, delay, vibrate
                val pattern = longArrayOf(0, 1000, 300, 1000, 300, 1000, 300, 1000)
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val vibrationEffect = VibrationEffect.createWaveform(pattern, -1)
                    vibrator.vibrate(vibrationEffect)
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(pattern, -1)
                }
                
                println("Emergency vibration triggered")
            } else {
                println("Device does not support vibration")
            }
        } catch (e: Exception) {
            println("Error triggering emergency vibration: ${e.message}")
        }
    }
}