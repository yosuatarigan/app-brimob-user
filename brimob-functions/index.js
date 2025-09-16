const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// Test function untuk memastikan deploy berhasil
// exports.helloWorld = functions.https.onRequest((req, res) => {
//   res.json({
//     message: "Hello from Brimob Cloud Functions!",
//     timestamp: new Date().toISOString(),
//     project: "app-toko-retail"
//   });
// });

// Main function untuk send notification
exports.sendNotification = functions.https.onCall(async (data, context) => {
  console.log('sendNotification called with data:', data);
  console.log('Context auth:', context.auth ? 'authenticated' : 'not authenticated');
  
  // Verify authentication
  if (!context.auth) {
    console.error('Authentication required');
    throw new functions.https.HttpsError(
      'unauthenticated', 
      'Must be authenticated to send notifications'
    );
  }

  try {
    // Verify user is admin
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .get();

    if (!userDoc.exists) {
      console.error('User document not found for UID:', context.auth.uid);
      throw new functions.https.HttpsError(
        'not-found', 
        'User document not found'
      );
    }

    const userData = userDoc.data();
    console.log('User data role:', userData.role);

    if (userData.role !== 'admin') {
      console.error('Permission denied. User role:', userData.role);
      throw new functions.https.HttpsError(
        'permission-denied', 
        'Only administrators can send notifications'
      );
    }

    // Extract and validate notification data
    const { title, message, targetRole, imageUrl, type, actionData } = data;

    if (!title || !message || !targetRole) {
      console.error('Missing required fields:', { title: !!title, message: !!message, targetRole: !!targetRole });
      throw new functions.https.HttpsError(
        'invalid-argument', 
        'Title, message, and targetRole are required'
      );
    }

    // Create notification document
    const notificationRef = admin.firestore().collection('notifications').doc();
    const notificationData = {
      id: notificationRef.id,
      title: title,
      message: message,
      targetRole: targetRole,
      senderName: userData.fullName || userData.name || 'Administrator',
      senderId: context.auth.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      imageUrl: imageUrl || null,
      type: type || 'general',
      actionData: actionData || null,
      status: 'sending'
    };

    await notificationRef.set(notificationData);
    console.log('Notification document created:', notificationRef.id);

    // Prepare FCM message
    const topic = `role_${targetRole}`;
    const fcmMessage = {
      topic: topic,
      notification: {
        title: title,
        body: message,
      },
      data: {
        notificationId: notificationRef.id,
        type: type || 'general',
        targetRole: targetRole,
        actionData: actionData || '',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
      android: {
        notification: {
          channelId: 'brimob_notifications',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true,
          icon: 'ic_launcher',
          color: '#1976D2',
        },
        data: {
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        }
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: title,
              body: message,
            },
            sound: 'default',
            badge: 1,
            category: 'GENERAL_NOTIFICATION',
          },
        },
      },
    };

    // Add image if provided
    if (imageUrl) {
      fcmMessage.notification.image = imageUrl;
      fcmMessage.android.notification.image = imageUrl;
      fcmMessage.apns.fcm_options = { image: imageUrl };
    }

    console.log('Sending FCM message to topic:', topic);

    // Send FCM message
    const response = await admin.messaging().send(fcmMessage);
    console.log('FCM message sent successfully:', response);

    // Update notification status to sent
    await notificationRef.update({
      status: 'sent',
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      fcmMessageId: response,
      recipientTopic: topic,
    });

    // Log successful send for analytics
    await admin.firestore().collection('notificationLogs').add({
      notificationId: notificationRef.id,
      senderId: context.auth.uid,
      senderName: userData.fullName || userData.name || 'Administrator',
      targetRole: targetRole,
      title: title,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      success: true,
      fcmResponse: response,
    });

    console.log('Notification sent successfully');

    return { 
      success: true, 
      notificationId: notificationRef.id,
      messageId: response,
      topic: topic,
      message: 'Notification sent successfully'
    };

  } catch (error) {
    console.error('Error sending notification:', error);

    // Log failed send
    if (data && context.auth) {
      try {
        await admin.firestore().collection('notificationLogs').add({
          senderId: context.auth.uid,
          targetRole: data.targetRole || 'unknown',
          title: data.title || 'unknown',
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          success: false,
          error: error.message,
          errorCode: error.code,
        });
      } catch (logError) {
        console.error('Error logging failed notification:', logError);
      }
    }

    // Re-throw the error for the client
    if (error instanceof functions.https.HttpsError) {
      throw error;
    } else {
      throw new functions.https.HttpsError(
        'internal', 
        'Failed to send notification: ' + error.message
      );
    }
  }
});

// Test function untuk cek koneksi Firestore
exports.testFirestore = functions.https.onCall(async (data, context) => {
  console.log('testFirestore called');
  
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  try {
    // Test read user document
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .get();

    console.log('User document exists:', userDoc.exists);
    if (userDoc.exists) {
      console.log('User data:', userDoc.data());
    }

    return {
      success: true,
      userExists: userDoc.exists,
      userData: userDoc.exists ? {
        role: userDoc.data()?.role,
        name: userDoc.data()?.fullName || userDoc.data()?.name,
        email: userDoc.data()?.email
      } : null,
      timestamp: new Date().toISOString(),
      userId: context.auth.uid
    };
  } catch (error) {
    console.error('Firestore test error:', error);
    throw new functions.https.HttpsError('internal', 'Firestore test failed: ' + error.message);
  }
});

// Function untuk mendapatkan statistik notifikasi (Admin only)
exports.getNotificationStats = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  try {
    // Verify admin
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .get();

    if (!userDoc.exists || userDoc.data().role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Admin access required');
    }

    // Get notification logs from last 30 days
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    
    const logsSnapshot = await admin.firestore()
      .collection('notificationLogs')
      .where('sentAt', '>=', thirtyDaysAgo)
      .orderBy('sentAt', 'desc')
      .limit(100)
      .get();

    const stats = {
      totalSent: 0,
      totalFailed: 0,
      byRole: {},
      byDate: {},
      recentLogs: []
    };

    logsSnapshot.docs.forEach(doc => {
      const log = doc.data();
      
      if (log.success) {
        stats.totalSent++;
      } else {
        stats.totalFailed++;
      }

      // Count by role
      const role = log.targetRole || 'unknown';
      stats.byRole[role] = (stats.byRole[role] || 0) + 1;

      // Count by date
      if (log.sentAt && log.sentAt.toDate) {
        const date = log.sentAt.toDate().toISOString().split('T')[0];
        stats.byDate[date] = (stats.byDate[date] || 0) + 1;
      }

      // Add to recent logs (limit 10)
      if (stats.recentLogs.length < 10) {
        stats.recentLogs.push({
          id: doc.id,
          targetRole: log.targetRole,
          title: log.title,
          senderName: log.senderName,
          success: log.success,
          sentAt: log.sentAt ? log.sentAt.toDate().toISOString() : null,
          error: log.error || null,
        });
      }
    });

    return stats;

  } catch (error) {
    console.error('Error getting notification stats:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get stats: ' + error.message);
  }
});