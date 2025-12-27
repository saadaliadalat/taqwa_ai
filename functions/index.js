/**
 * Taqwa AI - Cloud Functions Entry Point
 * 
 * Main entry point for all Firebase Cloud Functions.
 * Exposes REST endpoints for the Flutter mobile app.
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Import services
const { validateFirebaseToken, requireAuthContext } = require("./auth.middleware");
const { rateLimitMiddleware, createRateLimiter } = require("./utils/rateLimiter");
const aiHandler = require("./ai.handler");
const quranService = require("./quran.service");
const hadithService = require("./hadith.service");
const notifications = require("./notifications");
const firestoreModels = require("./firestore.models");

// ============================================
// EXPRESS APP SETUP
// ============================================

const app = express();

// Middleware
app.use(cors({ origin: true }));
app.use(express.json());

// Health check endpoint (no auth required)
app.get("/health", (req, res) => {
    res.json({
        status: "healthy",
        timestamp: new Date().toISOString(),
        version: "1.0.0",
    });
});

// ============================================
// AI Q&A ENDPOINTS
// ============================================

/**
 * Ask a question to Taqwa AI
 * POST /api/ask
 * Body: { question: string }
 * Returns: { answer, sources, references }
 */
app.post(
    "/api/ask",
    validateFirebaseToken,
    rateLimitMiddleware({ action: "ask", maxRequests: 20 }),
    async (req, res) => {
        try {
            const { question } = req.body;
            const uid = req.user.uid;

            if (!question || typeof question !== "string") {
                return res.status(400).json({
                    success: false,
                    error: "InvalidRequest",
                    message: "Question is required and must be a string.",
                });
            }

            if (question.length < 3 || question.length > 2000) {
                return res.status(400).json({
                    success: false,
                    error: "InvalidLength",
                    message: "Question must be between 3 and 2000 characters.",
                });
            }

            // Generate AI response
            const response = await aiHandler.generateResponse(question);

            if (!response.success) {
                return res.status(200).json(response);
            }

            // Save conversation to Firestore
            try {
                await firestoreModels.saveConversation(uid, {
                    prompt: question,
                    response: response.answer,
                    sources: response.sources,
                    references: response.references,
                });
            } catch (saveError) {
                console.warn("Failed to save conversation:", saveError.message);
                // Continue - don't fail the request if save fails
            }

            // Update user's last active timestamp
            try {
                await firestoreModels.updateUserLastActive(uid);
            } catch (e) {
                // Ignore
            }

            res.json(response);
        } catch (error) {
            console.error("Ask endpoint error:", error);
            res.status(500).json({
                success: false,
                error: "InternalError",
                message: "An error occurred while processing your question.",
            });
        }
    }
);

/**
 * Quick response without extensive reference lookup
 * POST /api/ask/quick
 */
app.post(
    "/api/ask/quick",
    validateFirebaseToken,
    rateLimitMiddleware({ action: "ask_quick", maxRequests: 30 }),
    async (req, res) => {
        try {
            const { question } = req.body;

            if (!question || typeof question !== "string") {
                return res.status(400).json({
                    success: false,
                    error: "InvalidRequest",
                    message: "Question is required.",
                });
            }

            const response = await aiHandler.generateQuickResponse(question);
            res.json(response);
        } catch (error) {
            console.error("Quick ask endpoint error:", error);
            res.status(500).json({
                success: false,
                error: "InternalError",
                message: "An error occurred.",
            });
        }
    }
);

// ============================================
// QURAN ENDPOINTS
// ============================================

/**
 * Get random Quran verse
 * GET /api/quran/random
 */
app.get("/api/quran/random", async (req, res) => {
    try {
        const verse = await quranService.getRandomVerse();
        res.json({ success: true, verse });
    } catch (error) {
        console.error("Random verse error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to fetch random verse",
        });
    }
});

/**
 * Get specific Ayah
 * GET /api/quran/:surah/:ayah
 */
app.get("/api/quran/:surah/:ayah", async (req, res) => {
    try {
        const surah = parseInt(req.params.surah);
        const ayah = parseInt(req.params.ayah);

        if (isNaN(surah) || isNaN(ayah) || surah < 1 || surah > 114) {
            return res.status(400).json({
                success: false,
                error: "Invalid surah or ayah number",
            });
        }

        const verse = await quranService.getAyah(surah, ayah);
        res.json({ success: true, verse });
    } catch (error) {
        console.error("Get ayah error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to fetch verse",
        });
    }
});

/**
 * Search Quran
 * GET /api/quran/search?q=keyword
 */
app.get("/api/quran/search", async (req, res) => {
    try {
        const { q: keyword } = req.query;

        if (!keyword || keyword.length < 2) {
            return res.status(400).json({
                success: false,
                error: "Search keyword must be at least 2 characters",
            });
        }

        const results = await quranService.searchQuran(keyword);
        res.json({ success: true, ...results });
    } catch (error) {
        console.error("Quran search error:", error);
        res.status(500).json({
            success: false,
            error: "Search failed",
        });
    }
});

/**
 * Explain a Quran verse using AI
 * POST /api/quran/explain
 */
app.post(
    "/api/quran/explain",
    validateFirebaseToken,
    rateLimitMiddleware({ action: "explain", maxRequests: 15 }),
    async (req, res) => {
        try {
            const { surah, ayah } = req.body;

            if (!surah || !ayah) {
                return res.status(400).json({
                    success: false,
                    error: "Surah and Ayah numbers are required",
                });
            }

            const explanation = await aiHandler.explainVerse(surah, ayah);
            res.json(explanation);
        } catch (error) {
            console.error("Explain verse error:", error);
            res.status(500).json({
                success: false,
                error: "Failed to explain verse",
            });
        }
    }
);

// ============================================
// HADITH ENDPOINTS
// ============================================

/**
 * Get random Hadith
 * GET /api/hadith/random
 */
app.get("/api/hadith/random", async (req, res) => {
    try {
        const collection = req.query.collection || "bukhari";
        const hadith = await hadithService.getRandomHadith(collection);
        res.json({ success: true, hadith });
    } catch (error) {
        console.error("Random hadith error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to fetch random hadith",
        });
    }
});

/**
 * Get specific Hadith
 * GET /api/hadith/:collection/:number
 */
app.get("/api/hadith/:collection/:number", async (req, res) => {
    try {
        const { collection, number } = req.params;
        const hadith = await hadithService.getHadith(collection, number);

        if (!hadith) {
            return res.status(404).json({
                success: false,
                error: "Hadith not found",
            });
        }

        res.json({ success: true, hadith });
    } catch (error) {
        console.error("Get hadith error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to fetch hadith",
        });
    }
});

/**
 * Get available hadith collections
 * GET /api/hadith/collections
 */
app.get("/api/hadith/collections", async (req, res) => {
    try {
        const collections = await hadithService.getCollections();
        res.json({ success: true, collections });
    } catch (error) {
        console.error("Get collections error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to fetch collections",
        });
    }
});

/**
 * Explain a Hadith using AI
 * POST /api/hadith/explain
 */
app.post(
    "/api/hadith/explain",
    validateFirebaseToken,
    rateLimitMiddleware({ action: "explain", maxRequests: 15 }),
    async (req, res) => {
        try {
            const { collection, hadithNumber } = req.body;

            if (!collection || !hadithNumber) {
                return res.status(400).json({
                    success: false,
                    error: "Collection and hadith number are required",
                });
            }

            const explanation = await aiHandler.explainHadith(collection, hadithNumber);
            res.json(explanation);
        } catch (error) {
            console.error("Explain hadith error:", error);
            res.status(500).json({
                success: false,
                error: "Failed to explain hadith",
            });
        }
    }
);

// ============================================
// USER ENDPOINTS
// ============================================

/**
 * Create or update user profile
 * POST /api/user/profile
 */
app.post("/api/user/profile", validateFirebaseToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const { name, notificationPreferences } = req.body;

        const userData = {
            name: name || req.user.name || "",
            email: req.user.email || "",
        };

        if (notificationPreferences) {
            userData.notificationPreferences = {
                dailyVerse: notificationPreferences.dailyVerse !== false,
                hadithReminder: notificationPreferences.hadithReminder !== false,
            };
        }

        const user = await firestoreModels.upsertUser(uid, userData);
        res.json({ success: true, user });
    } catch (error) {
        console.error("Update profile error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to update profile",
        });
    }
});

/**
 * Get user profile
 * GET /api/user/profile
 */
app.get("/api/user/profile", validateFirebaseToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const user = await firestoreModels.getUserById(uid);

        if (!user) {
            return res.status(404).json({
                success: false,
                error: "User not found",
            });
        }

        res.json({ success: true, user });
    } catch (error) {
        console.error("Get profile error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to get profile",
        });
    }
});

/**
 * Update notification preferences
 * PUT /api/user/notifications
 */
app.put("/api/user/notifications", validateFirebaseToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const { dailyVerse, hadithReminder, fcmToken } = req.body;

        const db = admin.firestore();
        const updateData = {
            "notificationPreferences.dailyVerse": dailyVerse !== false,
            "notificationPreferences.hadithReminder": hadithReminder !== false,
            lastActive: admin.firestore.FieldValue.serverTimestamp(),
        };

        await db.collection("users").doc(uid).update(updateData);

        // Save FCM token if provided
        if (fcmToken) {
            await notifications.registerDeviceToken(uid, fcmToken);
        }

        res.json({ success: true, message: "Preferences updated" });
    } catch (error) {
        console.error("Update notifications error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to update preferences",
        });
    }
});

// ============================================
// FAVORITES ENDPOINTS
// ============================================

/**
 * Save a favorite
 * POST /api/favorites
 */
app.post("/api/favorites", validateFirebaseToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const { type, referenceId, text, metadata } = req.body;

        if (!type || !referenceId || !text) {
            return res.status(400).json({
                success: false,
                error: "Type, referenceId, and text are required",
            });
        }

        const favorite = await firestoreModels.saveFavorite(uid, {
            type,
            referenceId,
            text,
            metadata,
        });

        res.json({ success: true, favorite });
    } catch (error) {
        console.error("Save favorite error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to save favorite",
        });
    }
});

/**
 * Get user's favorites
 * GET /api/favorites?type=quran
 */
app.get("/api/favorites", validateFirebaseToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const { type, limit } = req.query;

        const favorites = await firestoreModels.getFavorites(uid, {
            type,
            limit: limit ? parseInt(limit) : 100,
        });

        res.json({ success: true, favorites });
    } catch (error) {
        console.error("Get favorites error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to get favorites",
        });
    }
});

/**
 * Delete a favorite
 * DELETE /api/favorites/:itemId
 */
app.delete("/api/favorites/:itemId", validateFirebaseToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const { itemId } = req.params;

        await firestoreModels.deleteFavorite(uid, itemId);
        res.json({ success: true, message: "Favorite deleted" });
    } catch (error) {
        console.error("Delete favorite error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to delete favorite",
        });
    }
});

// ============================================
// CONVERSATION HISTORY ENDPOINTS
// ============================================

/**
 * Get conversation history
 * GET /api/conversations?limit=50&startAfter=id
 */
app.get("/api/conversations", validateFirebaseToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const { limit, startAfter } = req.query;

        const conversations = await firestoreModels.getConversationHistory(uid, {
            limit: limit ? parseInt(limit) : 50,
            startAfter,
        });

        res.json({ success: true, conversations });
    } catch (error) {
        console.error("Get conversations error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to get conversations",
        });
    }
});

// ============================================
// FCM TOKEN ENDPOINTS
// ============================================

/**
 * Register FCM device token
 * POST /api/fcm/register
 */
app.post("/api/fcm/register", validateFirebaseToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const { token } = req.body;

        if (!token) {
            return res.status(400).json({
                success: false,
                error: "FCM token is required",
            });
        }

        await notifications.registerDeviceToken(uid, token);
        res.json({ success: true, message: "Token registered" });
    } catch (error) {
        console.error("Register FCM token error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to register token",
        });
    }
});

/**
 * Unregister FCM device token
 * DELETE /api/fcm/unregister
 */
app.delete("/api/fcm/unregister", validateFirebaseToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        await notifications.unregisterDeviceToken(uid);
        res.json({ success: true, message: "Token unregistered" });
    } catch (error) {
        console.error("Unregister FCM token error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to unregister token",
        });
    }
});

// ============================================
// SYNC ENDPOINTS (For Hive Offline Support)
// ============================================

/**
 * Get sync data for offline storage
 * GET /api/sync?since=timestamp
 */
app.get("/api/sync", validateFirebaseToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const { since } = req.query;
        const sinceDate = since ? new Date(parseInt(since)) : null;

        const db = admin.firestore();
        const syncData = {
            user: null,
            conversations: [],
            favorites: [],
            syncTimestamp: Date.now(),
        };

        // Get user data
        const user = await firestoreModels.getUserById(uid);
        if (user) {
            syncData.user = user;
        }

        // Get conversations (limited for sync)
        let convQuery = db
            .collection("conversations")
            .doc(uid)
            .collection("messages")
            .orderBy("createdAt", "desc")
            .limit(100);

        if (sinceDate) {
            convQuery = convQuery.where("createdAt", ">", sinceDate);
        }

        const convSnapshot = await convQuery.get();
        syncData.conversations = convSnapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
            createdAt: doc.data().createdAt?.toMillis?.() || null,
        }));

        // Get favorites
        let favQuery = db
            .collection("favorites")
            .doc(uid)
            .collection("items")
            .orderBy("createdAt", "desc")
            .limit(500);

        if (sinceDate) {
            favQuery = favQuery.where("createdAt", ">", sinceDate);
        }

        const favSnapshot = await favQuery.get();
        syncData.favorites = favSnapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
            createdAt: doc.data().createdAt?.toMillis?.() || null,
        }));

        res.json({ success: true, ...syncData });
    } catch (error) {
        console.error("Sync error:", error);
        res.status(500).json({
            success: false,
            error: "Sync failed",
        });
    }
});

// ============================================
// EXPORT EXPRESS APP AS CLOUD FUNCTION
// ============================================

exports.api = functions
    .runWith({
        timeoutSeconds: 60,
        memory: "512MB",
    })
    .https.onRequest(app);

// ============================================
// SCHEDULED FUNCTIONS
// ============================================

/**
 * Send daily Quran verse - runs every day at 6:00 AM UTC
 */
exports.sendDailyVerse = functions.pubsub
    .schedule("0 6 * * *")
    .timeZone("UTC")
    .onRun(async (context) => {
        console.log("Sending daily Quran verse...");
        const result = await notifications.sendDailyQuranVerse();
        console.log("Daily verse result:", result);
        return null;
    });

/**
 * Send hadith reminder - runs every day at 12:00 PM UTC
 */
exports.sendHadithReminder = functions.pubsub
    .schedule("0 12 * * *")
    .timeZone("UTC")
    .onRun(async (context) => {
        console.log("Sending hadith reminder...");
        const result = await notifications.sendHadithReminder();
        console.log("Hadith reminder result:", result);
        return null;
    });

/**
 * Cleanup rate limit records - runs every day at 3:00 AM UTC
 */
exports.cleanupRateLimits = functions.pubsub
    .schedule("0 3 * * *")
    .timeZone("UTC")
    .onRun(async (context) => {
        console.log("Cleaning up rate limit records...");
        const limiter = createRateLimiter();
        const result = await limiter.cleanup();
        console.log("Cleanup result:", result);
        return null;
    });

// ============================================
// FIRESTORE TRIGGERS
// ============================================

/**
 * On user creation - initialize default preferences
 */
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
    console.log("New user created:", user.uid);

    try {
        await firestoreModels.upsertUser(user.uid, {
            name: user.displayName || "",
            email: user.email || "",
        });
        console.log("User document created for:", user.uid);
    } catch (error) {
        console.error("Error creating user document:", error);
    }

    return null;
});

/**
 * On user deletion - cleanup user data
 */
exports.onUserDelete = functions.auth.user().onDelete(async (user) => {
    console.log("User deleted:", user.uid);

    const db = admin.firestore();
    const batch = db.batch();

    try {
        // Delete user document
        batch.delete(db.collection("users").doc(user.uid));

        // Delete FCM token
        batch.delete(db.collection("fcmTokens").doc(user.uid));

        // Note: Conversations and favorites subcollections would need
        // recursive deletion (consider using Firebase Extensions for this)

        await batch.commit();
        console.log("User data cleaned up for:", user.uid);
    } catch (error) {
        console.error("Error cleaning up user data:", error);
    }

    return null;
});

// ============================================
// CALLABLE FUNCTIONS (Alternative to REST)
// ============================================

/**
 * Ask question - callable function
 */
exports.askQuestion = functions
    .runWith({ timeoutSeconds: 60, memory: "512MB" })
    .https.onCall(async (data, context) => {
        const user = requireAuthContext(context);
        const { question } = data;

        if (!question || typeof question !== "string") {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Question is required and must be a string."
            );
        }

        // Rate limiting for callable
        const limiter = createRateLimiter();
        const rateCheck = await limiter.checkLimit(user.uid, "askQuestion");

        if (!rateCheck.allowed) {
            throw new functions.https.HttpsError(
                "resource-exhausted",
                `Rate limit exceeded. Try again in ${rateCheck.retryAfter} seconds.`
            );
        }

        const response = await aiHandler.generateResponse(question);

        // Save conversation
        if (response.success) {
            try {
                await firestoreModels.saveConversation(user.uid, {
                    prompt: question,
                    response: response.answer,
                    sources: response.sources,
                    references: response.references,
                });
            } catch (e) {
                console.warn("Failed to save conversation:", e.message);
            }
        }

        return response;
    });

/**
 * Save favorite - callable function
 */
exports.saveFavoriteItem = functions.https.onCall(async (data, context) => {
    const user = requireAuthContext(context);
    const { type, referenceId, text, metadata } = data;

    if (!type || !referenceId || !text) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Type, referenceId, and text are required."
        );
    }

    const favorite = await firestoreModels.saveFavorite(user.uid, {
        type,
        referenceId,
        text,
        metadata,
    });

    return { success: true, favorite };
});

console.log("Taqwa AI Cloud Functions initialized");
