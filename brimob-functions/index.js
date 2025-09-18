// functions/index.js (UPDATED untuk Emergency)
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

// Helper function untuk mapping role ke topic (TIDAK BERUBAH)
function getRoleTopicName(roleName) {
  const roleTopicMap = {
    'admin': 'admin_users',
    'makoKor': 'mako_kor_users',
    'pasPelopor': 'pas_pelopor_users', 
    'pasGegana': 'pas_gegana_users',
    'pasbrimobI': 'pasbrimob_i_users',
    'pasbrimobII': 'pasbrimob_ii_users',
    'pasbrimobIII': 'pasbrimob_iii_users',
    'other': 'other_users'
  };
  
  return roleTopicMap[roleName] || 'other_users';
}

// TAMBAH: Helper untuk create emergency message
function createEmergencyMessage(data, targetTopic) {
  const isEmergency = data.type === 'urgent' || data.priority === 'emergency';
  
  if (isEmergency) {
    // Emergency message dengan setting khusus
    return {
      notification: {
        title: `🚨 ${data.title}`,
        body: data.message,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "emergency_channel",
          priority: "max",
          defaultSound: false, // Kita gunakan custom sound
          sound: "emergency_alert",
          vibrationPattern: [0, 1000, 500, 1000, 500, 1000],
          lightSettings: {
            color: "#FF0000",
            lightOnDurationMs: 1000,
            lightOffDurationMs: 500
          },
          sticky: true, // Tidak bisa di-swipe dismiss
          localOnly: false,
          defaultVibrateTimings: false,
          bypassDnd: true, // CRITICAL: Bypass Do Not Disturb
          category: "alarm", // Kategorikan sebagai alarm
          visibility: "public" // Tampil di lockscreen
        }
      },
      apns: {
        headers: {
          "apns-priority": "10", // Highest priority
          "apns-push-type": "alert"
        },
        payload: {
          aps: {
            alert: {
              title: `🚨 ${data.title}`,
              body: data.message
            },
            sound: {
              critical: 1, // CRITICAL: iOS critical alert
              name: "emergency_alert.aiff",
              volume: 1.0
            },
            badge: 1,
            interruptionLevel: "critical", // Bypass Focus/DND
            category: "EMERGENCY_ALERT"
          }
        }
      },
      data: {
        priority: "emergency",
        type: data.type || "urgent",
        senderName: data.senderName || 'Emergency System',
        timestamp: new Date().toISOString(),
        requireAcknowledgment: "true"
      },
      topic: targetTopic
    };
  } else {
    // Normal message
    return {
      notification: {
        title: data.title,
        body: data.message,
      },
      android: {
        priority: "high",
        notification: {
          channelId: data.type === 'announcement' ? 'urgent_channel' : 'normal_channel',
          priority: data.type === 'announcement' ? 'high' : 'default',
          sound: "default"
        }
      },
      apns: {
        headers: {
          "apns-priority": "5"
        },
        payload: {
          aps: {
            alert: {
              title: data.title,
              body: data.message
            },
            sound: "default",
            badge: 1
          }
        }
      },
      data: {
        priority: "normal",
        type: data.type || "general",
        senderName: data.senderName || 'Admin',
        timestamp: new Date().toISOString()
      },
      topic: targetTopic
    };
  }
}

// Function untuk notifikasi broadcast (UPDATED)
exports.sendNotificationToAll = onDocumentCreated("notifications/{docId}", async (event) => {
  const data = event.data.data();
  
  try {
    const message = createEmergencyMessage(data, "all_users");
    
    await getMessaging().send(message);
    
    if (data.type === 'urgent' || data.priority === 'emergency') {
      console.log("🚨 EMERGENCY broadcast sent successfully to all_users");
    } else {
      console.log("✅ Normal broadcast sent successfully to all_users");
    }
    
    // Log notification details
    console.log("📤 Broadcast details:", {
      title: data.title,
      type: data.type,
      priority: data.priority || 'normal',
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error("❌ Error sending broadcast notification:", error);
  }
});

// Function untuk notifikasi berdasarkan role/satuan (UPDATED)
exports.sendNotificationToRole = onDocumentCreated("role_notifications/{docId}", async (event) => {
  const data = event.data.data();
  
  try {
    const targetRole = data.targetRole;
    const targetTopic = getRoleTopicName(targetRole);
    
    const message = createEmergencyMessage(data, targetTopic);
    
    await getMessaging().send(message);
    
    if (data.type === 'urgent' || data.priority === 'emergency') {
      console.log(`🚨 EMERGENCY role notification sent successfully`);
    } else {
      console.log(`✅ Normal role notification sent successfully`);
    }
    
    console.log(`📤 Role notification details:`, {
      title: data.title,
      targetRole: targetRole,
      targetTopic: targetTopic,
      type: data.type,
      priority: data.priority || 'normal',
      senderName: data.senderName || 'Admin',
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error("❌ Error sending role notification:", error);
    console.error("📋 Failed notification data:", {
      title: data.title,
      targetRole: data.targetRole,
      type: data.type
    });
  }
});

// TAMBAH: Function khusus untuk emergency alerts
exports.sendEmergencyAlert = onDocumentCreated("emergency_alerts/{docId}", async (event) => {
  const data = event.data.data();
  
  try {
    console.log("🚨 EMERGENCY ALERT TRIGGERED");
    console.log("📋 Emergency data:", data);
    
    // Force emergency settings
    const emergencyData = {
      ...data,
      type: 'urgent',
      priority: 'emergency'
    };
    
    // Send to all users untuk emergency
    const message = createEmergencyMessage(emergencyData, "all_users");
    
    // Tambah emergency-specific settings
    message.android.notification.fullScreenIntent = true;
    message.android.notification.ongoing = true;
    message.data.emergencyLevel = data.emergencyLevel || 'critical';
    message.data.emergencyType = data.emergencyType || 'general';
    
    await getMessaging().send(message);
    
    console.log("🚨 EMERGENCY ALERT sent to all users");
    
    // Also send to specific roles if specified
    if (data.targetRoles && Array.isArray(data.targetRoles)) {
      for (const role of data.targetRoles) {
        const roleMessage = createEmergencyMessage(emergencyData, getRoleTopicName(role));
        await getMessaging().send(roleMessage);
        console.log(`🚨 EMERGENCY ALERT sent to role: ${role}`);
      }
    }
    
    // Log emergency alert
    console.log("📊 Emergency Alert Summary:", {
      title: data.title,
      emergencyLevel: data.emergencyLevel,
      emergencyType: data.emergencyType,
      targetRoles: data.targetRoles || ['all'],
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error("💥 CRITICAL ERROR sending emergency alert:", error);
  }
});

// TAMBAH: Function untuk test emergency notification
exports.testEmergencyNotification = onDocumentCreated("test_emergency/{docId}", async (event) => {
  const data = event.data.data();
  
  try {
    console.log("🧪 Testing emergency notification system");
    
    const testMessage = {
      notification: {
        title: "🚨 TEST EMERGENCY ALERT",
        body: "This is a test emergency notification. Please acknowledge.",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "emergency_channel",
          priority: "max",
          sound: "emergency_alert",
          vibrationPattern: [0, 1000, 500, 1000],
          lightSettings: {
            color: "#FF0000",
            lightOnDurationMs: 1000,
            lightOffDurationMs: 500
          },
          sticky: true,
          bypassDnd: true,
          category: "alarm"
        }
      },
      apns: {
        headers: {
          "apns-priority": "10"
        },
        payload: {
          aps: {
            alert: {
              title: "🚨 TEST EMERGENCY",
              body: "Test emergency notification"
            },
            sound: {
              critical: 1,
              name: "emergency_alert.aiff",
              volume: 1.0
            },
            interruptionLevel: "critical"
          }
        }
      },
      data: {
        priority: "emergency",
        type: "test",
        timestamp: new Date().toISOString(),
        testId: data.testId || 'unknown'
      },
      topic: data.testTopic || "all_users"
    };
    
    await getMessaging().send(testMessage);
    console.log("✅ Test emergency notification sent successfully");
    
  } catch (error) {
    console.error("❌ Error sending test emergency notification:", error);
  }
});

// Function untuk monitoring delivery (TAMBAH)
exports.notificationDeliveryMonitor = onDocumentCreated("delivery_reports/{docId}", async (event) => {
  const data = event.data.data();
  
  try {
    console.log("📊 Notification Delivery Report:");
    console.log(`  Message ID: ${data.messageId}`);
    console.log(`  Status: ${data.status}`);
    console.log(`  Delivery Time: ${data.deliveryTime}`);
    console.log(`  Target: ${data.target}`);
    console.log(`  Emergency: ${data.isEmergency || false}`);
    
    if (data.status === 'failed' && data.isEmergency) {
      console.error("🚨 CRITICAL: Emergency notification delivery failed!");
      console.error(`  Failed Target: ${data.target}`);
      console.error(`  Error: ${data.error}`);
      
      // TODO: Implement retry mechanism for failed emergency notifications
    }
    
  } catch (error) {
    console.error("❌ Error processing delivery report:", error);
  }
});

// Debug function (UPDATED)
exports.debugBrimobTopics = onDocumentCreated("debug/{docId}", async (event) => {
  console.log("🔍 === BRIMOB FCM TOPICS & EMERGENCY DEBUG ===");
  console.log("📋 Available FCM topics:");
  console.log("  🌐 all_users (broadcast to all)");
  console.log("  👑 admin_users (administrators)");
  console.log("  🏢 mako_kor_users (MAKO KOR)");
  console.log("  ⚡ pas_pelopor_users (PAS PELOPOR)");
  console.log("  💣 pas_gegana_users (PAS GEGANA)");
  console.log("  🛡️ pasbrimob_i_users (PASBRIMOB I)");
  console.log("  🛡️ pasbrimob_ii_users (PASBRIMOB II)");
  console.log("  🛡️ pasbrimob_iii_users (PASBRIMOB III)");
  console.log("");
  console.log("🚨 Emergency Notification Features:");
  console.log("  ✅ Bypass Silent Mode (Android/iOS)");
  console.log("  ✅ Critical Alerts (iOS)");
  console.log("  ✅ Bypass Do Not Disturb");
  console.log("  ✅ Full Screen Intent (Android)");
  console.log("  ✅ Custom Emergency Sounds");
  console.log("  ✅ Strong Vibration Patterns");
  console.log("  ✅ LED Light Notifications");
  console.log("===========================================");
});

// TAMBAH: Emergency system status check
exports.emergencySystemHealthCheck = onDocumentCreated("health_check/{docId}", async (event) => {
  try {
    console.log("🏥 Emergency System Health Check");
    
    // Test connectivity
    const testMessage = {
      data: {
        healthCheck: "true",
        timestamp: new Date().toISOString()
      },
      topic: "all_users"
    };
    
    await getMessaging().send(testMessage);
    console.log("✅ Emergency system operational");
    
  } catch (error) {
    console.error("🚨 CRITICAL: Emergency system health check failed!");
    console.error("Error:", error);
  }
});