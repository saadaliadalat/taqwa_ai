/**
 * Firestore Data Models for Taqwa AI
 * 
 * Provides helper functions for creating, validating, and managing
 * Firestore documents with consistent schemas.
 */

const admin = require("firebase-admin");

// ============================================
// USER MODEL
// ============================================

/**
 * Create a new user document
 * @param {string} uid - Firebase Auth UID
 * @param {Object} data - User data
 * @returns {Object} User document data
 */
const createUserDocument = (uid, data = {}) => {
    const now = admin.firestore.FieldValue.serverTimestamp();

    return {
        uid,
        name: data.name || "",
        email: data.email || "",
        createdAt: now,
        lastActive: now,
        notificationPreferences: {
            dailyVerse: data.dailyVerse !== undefined ? data.dailyVerse : true,
            hadithReminder: data.hadithReminder !== undefined ? data.hadithReminder : true,
        },
        // Sync metadata for offline support
        syncVersion: 1,
        lastSyncedAt: now,
    };
};

/**
 * Update user's last active timestamp
 * @param {string} uid - User ID
 * @returns {Promise<void>}
 */
const updateUserLastActive = async (uid) => {
    const db = admin.firestore();
    await db.collection("users").doc(uid).update({
        lastActive: admin.firestore.FieldValue.serverTimestamp(),
    });
};

/**
 * Get user by ID
 * @param {string} uid - User ID
 * @returns {Promise<Object|null>} User data or null
 */
const getUserById = async (uid) => {
    const db = admin.firestore();
    const doc = await db.collection("users").doc(uid).get();

    if (!doc.exists) {
        return null;
    }

    return { id: doc.id, ...doc.data() };
};

/**
 * Create or update user document
 * @param {string} uid - User ID
 * @param {Object} data - User data
 * @returns {Promise<Object>} Created/updated user
 */
const upsertUser = async (uid, data) => {
    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);
    const doc = await userRef.get();

    if (!doc.exists) {
        const userData = createUserDocument(uid, data);
        await userRef.set(userData);
        return userData;
    } else {
        const updateData = {
            ...data,
            lastActive: admin.firestore.FieldValue.serverTimestamp(),
            syncVersion: admin.firestore.FieldValue.increment(1),
        };
        await userRef.update(updateData);
        return { id: uid, ...doc.data(), ...updateData };
    }
};

// ============================================
// CONVERSATION MODEL
// ============================================

/**
 * Valid source types for conversations
 */
const VALID_SOURCES = ["Quran", "Hadith", "AI"];

/**
 * Create a new conversation document
 * @param {Object} data - Conversation data
 * @returns {Object} Conversation document data
 */
const createConversationDocument = (data) => {
    // Validate sources
    const sources = (data.sources || ["AI"]).filter(
        (source) => VALID_SOURCES.includes(source)
    );

    return {
        prompt: data.prompt || "",
        response: data.response || "",
        sources: sources.length > 0 ? sources : ["AI"],
        references: data.references || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        // Sync metadata
        syncId: `conv_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    };
};

/**
 * Save a conversation for a user
 * @param {string} uid - User ID
 * @param {Object} data - Conversation data
 * @returns {Promise<Object>} Saved conversation with ID
 */
const saveConversation = async (uid, data) => {
    const db = admin.firestore();
    const conversationData = createConversationDocument(data);

    const docRef = await db
        .collection("conversations")
        .doc(uid)
        .collection("messages")
        .add(conversationData);

    return { id: docRef.id, ...conversationData };
};

/**
 * Get conversation history for a user
 * @param {string} uid - User ID
 * @param {Object} options - Query options
 * @returns {Promise<Array>} List of conversations
 */
const getConversationHistory = async (uid, options = {}) => {
    const db = admin.firestore();
    const { limit = 50, startAfter = null } = options;

    let query = db
        .collection("conversations")
        .doc(uid)
        .collection("messages")
        .orderBy("createdAt", "desc")
        .limit(limit);

    if (startAfter) {
        const startDoc = await db
            .collection("conversations")
            .doc(uid)
            .collection("messages")
            .doc(startAfter)
            .get();

        if (startDoc.exists) {
            query = query.startAfter(startDoc);
        }
    }

    const snapshot = await query.get();

    return snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate?.() || null,
    }));
};

// ============================================
// FAVORITES MODEL
// ============================================

/**
 * Valid favorite types
 */
const VALID_FAVORITE_TYPES = ["quran", "hadith", "ai"];

/**
 * Create a new favorite document
 * @param {Object} data - Favorite data
 * @returns {Object} Favorite document data
 */
const createFavoriteDocument = (data) => {
    if (!VALID_FAVORITE_TYPES.includes(data.type)) {
        throw new Error(`Invalid favorite type. Must be one of: ${VALID_FAVORITE_TYPES.join(", ")}`);
    }

    return {
        type: data.type,
        referenceId: data.referenceId || "",
        text: data.text || "",
        metadata: data.metadata || {},
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        // Sync metadata
        syncId: `fav_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    };
};

/**
 * Save a favorite for a user
 * @param {string} uid - User ID
 * @param {Object} data - Favorite data
 * @returns {Promise<Object>} Saved favorite with ID
 */
const saveFavorite = async (uid, data) => {
    const db = admin.firestore();
    const favoriteData = createFavoriteDocument(data);

    // Check for duplicates based on type and referenceId
    const existingQuery = await db
        .collection("favorites")
        .doc(uid)
        .collection("items")
        .where("type", "==", data.type)
        .where("referenceId", "==", data.referenceId)
        .limit(1)
        .get();

    if (!existingQuery.empty) {
        const existingDoc = existingQuery.docs[0];
        return { id: existingDoc.id, ...existingDoc.data(), alreadyExists: true };
    }

    const docRef = await db
        .collection("favorites")
        .doc(uid)
        .collection("items")
        .add(favoriteData);

    return { id: docRef.id, ...favoriteData };
};

/**
 * Get favorites for a user
 * @param {string} uid - User ID
 * @param {Object} options - Query options
 * @returns {Promise<Array>} List of favorites
 */
const getFavorites = async (uid, options = {}) => {
    const db = admin.firestore();
    const { type = null, limit = 100 } = options;

    let query = db
        .collection("favorites")
        .doc(uid)
        .collection("items")
        .orderBy("createdAt", "desc")
        .limit(limit);

    if (type && VALID_FAVORITE_TYPES.includes(type)) {
        query = query.where("type", "==", type);
    }

    const snapshot = await query.get();

    return snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate?.() || null,
    }));
};

/**
 * Delete a favorite
 * @param {string} uid - User ID
 * @param {string} itemId - Favorite item ID
 * @returns {Promise<boolean>} Success status
 */
const deleteFavorite = async (uid, itemId) => {
    const db = admin.firestore();

    await db
        .collection("favorites")
        .doc(uid)
        .collection("items")
        .doc(itemId)
        .delete();

    return true;
};

// ============================================
// FCM TOKEN MODEL
// ============================================

/**
 * Save or update FCM token for a user
 * @param {string} uid - User ID
 * @param {string} token - FCM token
 * @returns {Promise<void>}
 */
const saveFcmToken = async (uid, token) => {
    const db = admin.firestore();

    await db.collection("fcmTokens").doc(uid).set({
        token,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
};

/**
 * Get FCM token for a user
 * @param {string} uid - User ID
 * @returns {Promise<string|null>} FCM token or null
 */
const getFcmToken = async (uid) => {
    const db = admin.firestore();
    const doc = await db.collection("fcmTokens").doc(uid).get();

    return doc.exists ? doc.data().token : null;
};

/**
 * Get all users with notification preferences enabled
 * @param {string} preference - Preference key (dailyVerse or hadithReminder)
 * @returns {Promise<Array>} List of user IDs with FCM tokens
 */
const getUsersWithNotificationEnabled = async (preference) => {
    const db = admin.firestore();

    const usersSnapshot = await db.collection("users")
        .where(`notificationPreferences.${preference}`, "==", true)
        .get();

    const userIds = usersSnapshot.docs.map((doc) => doc.id);

    // Get FCM tokens for these users
    const tokensPromises = userIds.map(async (uid) => {
        const token = await getFcmToken(uid);
        return token ? { uid, token } : null;
    });

    const results = await Promise.all(tokensPromises);
    return results.filter((r) => r !== null);
};

module.exports = {
    // User
    createUserDocument,
    updateUserLastActive,
    getUserById,
    upsertUser,
    // Conversation
    VALID_SOURCES,
    createConversationDocument,
    saveConversation,
    getConversationHistory,
    // Favorites
    VALID_FAVORITE_TYPES,
    createFavoriteDocument,
    saveFavorite,
    getFavorites,
    deleteFavorite,
    // FCM
    saveFcmToken,
    getFcmToken,
    getUsersWithNotificationEnabled,
};
