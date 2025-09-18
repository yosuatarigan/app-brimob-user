// functions/index.js - SEMUA NOTIFIKASI BYPASS SILENT MODE
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

// Helper function - SEMUA NOTIFIKASI BYPASS SILENT MODE (CORRECTED)
function createMessage(data, topic) {
  return {
    notification: {
      title: data.title,
      body: data.message,
    },
    android: {
      priority: "high",
      notification: {
        channelId: "bypass_silent_channel",
        priority: "high",
        defaultSound: true,
        defaultVibrateTimings: false,
        // Field yang VALID untuk FCM Android
        sound: "default",
        tag: "bypass_silent",
        color: "#FF0000",
        sticky: false,
        localOnly: false,
        visibility: "public"
      }
    },
    apns: {
      headers: {
        "apns-priority": "10",
        "apns-push-type": "alert"
      },
      payload: {
        aps: {
          alert: {
            title: data.title,
            body: data.message
          },
          sound: "default",
          badge: 1,
          // BYPASS SILENT MODE iOS - CRITICAL LEVEL
          "interruption-level": "critical"
        }
      }
    },
    data: {
      bypassSilent: "true",
      forceSound: "true",
      priority: "high",
      timestamp: new Date().toISOString()
    },
    topic: topic
  };
}

// Function untuk notifikasi broadcast (semua user)
exports.sendNotificationToAll = onDocumentCreated("notifications/{docId}", async (event) => {
  const data = event.data.data();
  
  const message = createMessage(data, "all_users");

  try {
    await getMessaging().send(message);
    console.log("🔊 Broadcast notification sent - BYPASS SILENT MODE ACTIVE");
  } catch (error) {
    console.error("Error sending broadcast notification:", error);
  }
});

// Function untuk notifikasi berdasarkan role/satuan
exports.sendNotificationToRole = onDocumentCreated("role_notifications/{docId}", async (event) => {
  const data = event.data.data();
  
  const message = createMessage(data, data.targetTopic);

  try {
    await getMessaging().send(message);
    console.log(`🔊 Role notification sent to: ${data.targetTopic} - BYPASS SILENT MODE`);
    
    // Log info
    console.log(`Notification details:`, {
      title: data.title,
      targetRole: data.targetRole,
      topic: data.targetTopic,
      bypassSilent: true,
      forceSound: true
    });
  } catch (error) {
    console.error("Error sending role notification:", error);
  }
});

// Debug topics - SEMUA BYPASS SILENT MODE
exports.debugTopics = onDocumentCreated("debug/{docId}", async (event) => {
  console.log("🔊 ALL FCM topics BYPASS SILENT MODE - NO EXCEPTIONS:");
  console.log("- all_users (FORCE SOUND)");
  console.log("- admin_users (FORCE SOUND)");
  console.log("- mako_kor_users (FORCE SOUND)");
  console.log("- pas_pelopor_users (FORCE SOUND)");
  console.log("- pas_gegana_users (FORCE SOUND)");
  console.log("- pasbrimob_i_users (FORCE SOUND)");
  console.log("- pasbrimob_ii_users (FORCE SOUND)");
  console.log("- pasbrimob_iii_users (FORCE SOUND)");
  console.log("✅ Priority: MAXIMUM | BypassDND: TRUE | InterruptionLevel: CRITICAL");
});