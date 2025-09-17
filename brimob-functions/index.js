// functions/index.js
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

// Function untuk notifikasi broadcast (semua user)
exports.sendNotificationToAll = onDocumentCreated("notifications/{docId}", async (event) => {
  const data = event.data.data();
  
  const message = {
    notification: {
      title: data.title,
      body: data.message,
    },
    topic: "all_users"
  };

  try {
    await getMessaging().send(message);
    console.log("Broadcast notification sent successfully to all_users");
  } catch (error) {
    console.error("Error sending broadcast notification:", error);
  }
});

// Function untuk notifikasi berdasarkan role/satuan BRIMOB
exports.sendNotificationToRole = onDocumentCreated("role_notifications/{docId}", async (event) => {
  const data = event.data.data();
  
  const message = {
    notification: {
      title: data.title,
      body: data.message,
    },
    topic: data.targetTopic // akan berisi topic seperti "mako_kor_users", "pas_pelopor_users", dll
  };

  try {
    await getMessaging().send(message);
    console.log(`Role notification sent successfully to topic: ${data.targetTopic}`);
    
    // Log additional info
    console.log(`Notification details:`, {
      title: data.title,
      targetRole: data.targetRole,
      topic: data.targetTopic,
      senderName: data.senderName || 'Admin',
      type: data.type || 'general'
    });
  } catch (error) {
    console.error("Error sending role notification:", error);
    console.error("Failed notification data:", {
      title: data.title,
      topic: data.targetTopic,
      targetRole: data.targetRole
    });
  }
});

// Optional: Function untuk debugging - melihat semua topics BRIMOB yang ada
exports.debugBrimobTopics = onDocumentCreated("debug/{docId}", async (event) => {
  console.log("Available FCM topics for BRIMOB app:");
  console.log("- all_users (broadcast)");
  console.log("- admin_users");
  console.log("- mako_kor_users (MAKO KOR)");
  console.log("- pas_pelopor_users (PAS PELOPOR)");
  console.log("- pas_gegana_users (PAS GEGANA)");
  console.log("- pasbrimob_i_users (PASBRIMOB I)");
  console.log("- pasbrimob_ii_users (PASBRIMOB II)");
  console.log("- pasbrimob_iii_users (PASBRIMOB III)");
});