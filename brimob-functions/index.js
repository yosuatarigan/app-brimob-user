const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

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
    console.log("Notification sent successfully");
  } catch (error) {
    console.error("Error sending notification:", error);
  }
});