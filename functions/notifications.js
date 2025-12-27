/**
 * Notifications Service for Taqwa AI
 * 
 * Handles Firebase Cloud Messaging (FCM) for push notifications
 * including daily Quran verses and Hadith reminders.
 */

const admin = require("firebase-admin");
const quranService = require("./quran.service");
const hadithService = require("./hadith.service");
const { getUsersWithNotificationEnabled, saveFcmToken } = require("./firestore.models");

// ============================================
// FCM CONFIGURATION
// ============================================

/**
 * Send a push notification to a single device
 * @param {string} token - FCM device token
 * @param {Object} notification - Notification payload
 * @param {Object} data - Additional data payload
 * @returns {Promise<Object>} Send result
 */
const sendNotification = async (token, notification, data = {}) => {
    const message = {
        token,
        notification: {
            title: notification.title,
            body: notification.body,
        },
        data: {
            ...data,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
            notification: {
                icon: "ic_notification",
                color: "#1B5E20",
                channelId: "taqwa_ai_channel",
            },
            priority: "high",
        },
        apns: {
            payload: {
                aps: {
                    badge: 1,
                    sound: "default",
                },
            },
        },
    };

    try {
        const response = await admin.messaging().send(message);
        return { success: true, messageId: response };
    } catch (error) {
        console.error("Error sending notification:", error);

        // Handle invalid tokens
        if (
            error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered"
        ) {
            return { success: false, error: "invalid_token", shouldRemove: true };
        }

        return { success: false, error: error.message };
    }
};

/**
 * Send notifications to multiple devices
 * @param {Array<string>} tokens - List of FCM tokens
 * @param {Object} notification - Notification payload
 * @param {Object} data - Additional data payload
 * @returns {Promise<Object>} Batch send results
 */
const sendMulticastNotification = async (tokens, notification, data = {}) => {
    if (!tokens || tokens.length === 0) {
        return { success: true, successCount: 0, failureCount: 0 };
    }

    const message = {
        tokens,
        notification: {
            title: notification.title,
            body: notification.body,
        },
        data: {
            ...data,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
            notification: {
                icon: "ic_notification",
                color: "#1B5E20",
                channelId: "taqwa_ai_channel",
            },
            priority: "high",
        },
        apns: {
            payload: {
                aps: {
                    badge: 1,
                    sound: "default",
                },
            },
        },
    };

    try {
        const response = await admin.messaging().sendEachForMulticast(message);

        // Collect failed tokens for cleanup
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
            if (!resp.success) {
                if (
                    resp.error?.code === "messaging/invalid-registration-token" ||
                    resp.error?.code === "messaging/registration-token-not-registered"
                ) {
                    failedTokens.push(tokens[idx]);
                }
            }
        });

        return {
            success: true,
            successCount: response.successCount,
            failureCount: response.failureCount,
            failedTokens,
        };
    } catch (error) {
        console.error("Error sending multicast notification:", error);
        return { success: false, error: error.message };
    }
};

// ============================================
// DAILY QURAN VERSE
// ============================================

/**
 * Send daily Quran verse notification to all subscribed users
 * @returns {Promise<Object>} Send results
 */
const sendDailyQuranVerse = async () => {
    try {
        // Get a random verse
        const verse = await quranService.getRandomVerse();

        // Build notification content
        const notification = {
            title: "📖 Daily Quran Verse",
            body: truncateText(verse.textTranslation, 150),
        };

        const data = {
            type: "daily_verse",
            surah: String(verse.surah),
            surahName: verse.surahName,
            ayah: String(verse.ayah),
            textArabic: verse.textArabic,
            textTranslation: verse.textTranslation,
        };

        // Get all users with daily verse enabled
        const users = await getUsersWithNotificationEnabled("dailyVerse");

        if (users.length === 0) {
            return { success: true, message: "No users subscribed to daily verse" };
        }

        const tokens = users.map((u) => u.token);
        const result = await sendMulticastNotification(tokens, notification, data);

        // Log results
        console.log(`Daily verse sent. Success: ${result.successCount}, Failed: ${result.failureCount}`);

        return {
            ...result,
            verse: {
                surah: verse.surah,
                surahName: verse.surahName,
                ayah: verse.ayah,
            },
        };
    } catch (error) {
        console.error("Error sending daily Quran verse:", error);
        return { success: false, error: error.message };
    }
};

// ============================================
// HADITH REMINDER
// ============================================

/**
 * Send hadith reminder notification to all subscribed users
 * @returns {Promise<Object>} Send results
 */
const sendHadithReminder = async () => {
    try {
        // Get a random hadith
        const hadith = await hadithService.getRandomHadith();

        // Build notification content
        const notification = {
            title: "🕌 Hadith of the Day",
            body: truncateText(hadith.textEnglish || hadith.textArabic, 150),
        };

        const data = {
            type: "hadith_reminder",
            collection: hadith.collection,
            collectionName: hadith.collectionName,
            hadithNumber: String(hadith.hadithNumber),
            textArabic: hadith.textArabic || "",
            textEnglish: hadith.textEnglish || "",
            grade: hadith.grade || "",
        };

        // Get all users with hadith reminder enabled
        const users = await getUsersWithNotificationEnabled("hadithReminder");

        if (users.length === 0) {
            return { success: true, message: "No users subscribed to hadith reminder" };
        }

        const tokens = users.map((u) => u.token);
        const result = await sendMulticastNotification(tokens, notification, data);

        // Log results
        console.log(`Hadith reminder sent. Success: ${result.successCount}, Failed: ${result.failureCount}`);

        return {
            ...result,
            hadith: {
                collection: hadith.collection,
                hadithNumber: hadith.hadithNumber,
            },
        };
    } catch (error) {
        console.error("Error sending hadith reminder:", error);
        return { success: false, error: error.message };
    }
};

// ============================================
// USER TOKEN MANAGEMENT
// ============================================

/**
 * Register a device token for a user
 * @param {string} uid - User ID
 * @param {string} token - FCM device token
 * @returns {Promise<Object>} Registration result
 */
const registerDeviceToken = async (uid, token) => {
    if (!uid || !token) {
        return { success: false, error: "User ID and token are required" };
    }

    try {
        await saveFcmToken(uid, token);
        return { success: true, message: "Token registered successfully" };
    } catch (error) {
        console.error("Error registering device token:", error);
        return { success: false, error: error.message };
    }
};

/**
 * Unregister a device token for a user
 * @param {string} uid - User ID
 * @returns {Promise<Object>} Unregistration result
 */
const unregisterDeviceToken = async (uid) => {
    if (!uid) {
        return { success: false, error: "User ID is required" };
    }

    try {
        const db = admin.firestore();
        await db.collection("fcmTokens").doc(uid).delete();
        return { success: true, message: "Token unregistered successfully" };
    } catch (error) {
        console.error("Error unregistering device token:", error);
        return { success: false, error: error.message };
    }
};

// ============================================
// CUSTOM NOTIFICATIONS
// ============================================

/**
 * Send a custom notification to a specific user
 * @param {string} uid - User ID
 * @param {Object} notification - Notification payload
 * @param {Object} data - Additional data
 * @returns {Promise<Object>} Send result
 */
const sendNotificationToUser = async (uid, notification, data = {}) => {
    const db = admin.firestore();
    const tokenDoc = await db.collection("fcmTokens").doc(uid).get();

    if (!tokenDoc.exists) {
        return { success: false, error: "User has no registered device" };
    }

    const token = tokenDoc.data().token;
    return sendNotification(token, notification, data);
};

/**
 * Send notification to multiple users by UID
 * @param {Array<string>} uids - List of user IDs
 * @param {Object} notification - Notification payload
 * @param {Object} data - Additional data
 * @returns {Promise<Object>} Send results
 */
const sendNotificationToUsers = async (uids, notification, data = {}) => {
    const db = admin.firestore();
    const tokens = [];

    for (const uid of uids) {
        const tokenDoc = await db.collection("fcmTokens").doc(uid).get();
        if (tokenDoc.exists) {
            tokens.push(tokenDoc.data().token);
        }
    }

    if (tokens.length === 0) {
        return { success: true, message: "No valid device tokens found" };
    }

    return sendMulticastNotification(tokens, notification, data);
};

// ============================================
// TOPIC SUBSCRIPTIONS
// ============================================

/**
 * Subscribe a token to a topic
 * @param {string} token - FCM device token
 * @param {string} topic - Topic name
 * @returns {Promise<Object>} Subscription result
 */
const subscribeToTopic = async (token, topic) => {
    try {
        await admin.messaging().subscribeToTopic(token, topic);
        return { success: true, message: `Subscribed to ${topic}` };
    } catch (error) {
        console.error("Error subscribing to topic:", error);
        return { success: false, error: error.message };
    }
};

/**
 * Unsubscribe a token from a topic
 * @param {string} token - FCM device token
 * @param {string} topic - Topic name
 * @returns {Promise<Object>} Unsubscription result
 */
const unsubscribeFromTopic = async (token, topic) => {
    try {
        await admin.messaging().unsubscribeFromTopic(token, topic);
        return { success: true, message: `Unsubscribed from ${topic}` };
    } catch (error) {
        console.error("Error unsubscribing from topic:", error);
        return { success: false, error: error.message };
    }
};

/**
 * Send notification to all subscribers of a topic
 * @param {string} topic - Topic name
 * @param {Object} notification - Notification payload
 * @param {Object} data - Additional data
 * @returns {Promise<Object>} Send result
 */
const sendNotificationToTopic = async (topic, notification, data = {}) => {
    const message = {
        topic,
        notification: {
            title: notification.title,
            body: notification.body,
        },
        data: {
            ...data,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
    };

    try {
        const response = await admin.messaging().send(message);
        return { success: true, messageId: response };
    } catch (error) {
        console.error("Error sending topic notification:", error);
        return { success: false, error: error.message };
    }
};

// ============================================
// UTILITY FUNCTIONS
// ============================================

/**
 * Truncate text to a maximum length
 * @param {string} text - Text to truncate
 * @param {number} maxLength - Maximum length
 * @returns {string} Truncated text
 */
const truncateText = (text, maxLength) => {
    if (!text) return "";
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - 3) + "...";
};

/**
 * Clean up invalid FCM tokens
 * @param {Array<string>} invalidTokens - List of invalid tokens
 * @returns {Promise<number>} Number of tokens removed
 */
const cleanupInvalidTokens = async (invalidTokens) => {
    if (!invalidTokens || invalidTokens.length === 0) {
        return 0;
    }

    const db = admin.firestore();
    const tokensCollection = db.collection("fcmTokens");

    let removedCount = 0;

    // Find and remove documents with invalid tokens
    const snapshot = await tokensCollection
        .where("token", "in", invalidTokens.slice(0, 10))
        .get();

    const batch = db.batch();
    snapshot.forEach((doc) => {
        batch.delete(doc.ref);
        removedCount++;
    });

    if (removedCount > 0) {
        await batch.commit();
    }

    return removedCount;
};

module.exports = {
    // Basic notifications
    sendNotification,
    sendMulticastNotification,

    // Scheduled notifications
    sendDailyQuranVerse,
    sendHadithReminder,

    // Token management
    registerDeviceToken,
    unregisterDeviceToken,

    // User notifications
    sendNotificationToUser,
    sendNotificationToUsers,

    // Topic subscriptions
    subscribeToTopic,
    unsubscribeFromTopic,
    sendNotificationToTopic,

    // Utilities
    truncateText,
    cleanupInvalidTokens,
};
