/**
 * Rate Limiter Utility for Taqwa AI
 * 
 * Implements token bucket rate limiting using Firestore
 * to prevent API abuse and ensure fair usage.
 */

const admin = require("firebase-admin");

// Default configuration
const DEFAULT_MAX_REQUESTS = 30;
const DEFAULT_WINDOW_MS = 60000; // 1 minute

/**
 * Rate limiter class using Firestore for state management
 */
class RateLimiter {
    /**
     * Create a new rate limiter instance
     * @param {Object} options - Configuration options
     * @param {number} options.maxRequests - Maximum requests per window
     * @param {number} options.windowMs - Time window in milliseconds
     * @param {string} options.collectionName - Firestore collection for rate limits
     */
    constructor(options = {}) {
        this.maxRequests = options.maxRequests ||
            parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) ||
            DEFAULT_MAX_REQUESTS;
        this.windowMs = options.windowMs ||
            parseInt(process.env.RATE_LIMIT_WINDOW_MS) ||
            DEFAULT_WINDOW_MS;
        this.collectionName = options.collectionName || "rateLimits";
        this.db = admin.firestore();
    }

    /**
     * Check if a request should be allowed based on rate limits
     * @param {string} identifier - Unique identifier (usually user ID)
     * @param {string} action - Action being rate limited (e.g., 'askQuestion')
     * @returns {Promise<Object>} Rate limit status
     */
    async checkLimit(identifier, action = "default") {
        const docRef = this.db
            .collection(this.collectionName)
            .doc(`${identifier}_${action}`);

        const now = Date.now();
        const windowStart = now - this.windowMs;

        try {
            const result = await this.db.runTransaction(async (transaction) => {
                const doc = await transaction.get(docRef);

                if (!doc.exists) {
                    // First request - create new record
                    transaction.set(docRef, {
                        requests: [now],
                        identifier,
                        action,
                        createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    });

                    return {
                        allowed: true,
                        remaining: this.maxRequests - 1,
                        resetAt: now + this.windowMs,
                        total: this.maxRequests,
                    };
                }

                const data = doc.data();
                // Filter out requests outside the current window
                const recentRequests = (data.requests || []).filter(
                    (timestamp) => timestamp > windowStart
                );

                if (recentRequests.length >= this.maxRequests) {
                    // Rate limit exceeded
                    const oldestRequest = Math.min(...recentRequests);
                    const resetAt = oldestRequest + this.windowMs;

                    return {
                        allowed: false,
                        remaining: 0,
                        resetAt,
                        total: this.maxRequests,
                        retryAfter: Math.ceil((resetAt - now) / 1000),
                    };
                }

                // Allow request and update record
                recentRequests.push(now);
                transaction.update(docRef, {
                    requests: recentRequests,
                    lastRequestAt: admin.firestore.FieldValue.serverTimestamp(),
                });

                return {
                    allowed: true,
                    remaining: this.maxRequests - recentRequests.length,
                    resetAt: Math.min(...recentRequests) + this.windowMs,
                    total: this.maxRequests,
                };
            });

            return result;
        } catch (error) {
            console.error("Rate limiter error:", error);
            // On error, allow the request but log the issue
            return {
                allowed: true,
                remaining: this.maxRequests,
                resetAt: now + this.windowMs,
                total: this.maxRequests,
                error: "Rate limiter temporarily unavailable",
            };
        }
    }

    /**
     * Reset rate limit for a specific identifier
     * @param {string} identifier - Unique identifier
     * @param {string} action - Action to reset
     */
    async resetLimit(identifier, action = "default") {
        const docRef = this.db
            .collection(this.collectionName)
            .doc(`${identifier}_${action}`);

        try {
            await docRef.delete();
            return { success: true };
        } catch (error) {
            console.error("Failed to reset rate limit:", error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Clean up expired rate limit records
     * Should be run periodically via a scheduled function
     */
    async cleanup() {
        const cutoff = Date.now() - this.windowMs * 2;
        const snapshot = await this.db
            .collection(this.collectionName)
            .where("lastRequestAt", "<", new Date(cutoff))
            .limit(500)
            .get();

        const batch = this.db.batch();
        let deleteCount = 0;

        snapshot.forEach((doc) => {
            batch.delete(doc.ref);
            deleteCount++;
        });

        if (deleteCount > 0) {
            await batch.commit();
        }

        return { deleted: deleteCount };
    }
}

/**
 * Express middleware factory for rate limiting
 * @param {Object} options - Rate limiter options
 * @returns {Function} Express middleware
 */
const rateLimitMiddleware = (options = {}) => {
    const limiter = new RateLimiter(options);
    const action = options.action || "api";

    return async (req, res, next) => {
        // Use user ID if authenticated, otherwise use IP
        const identifier = req.user?.uid ||
            req.ip ||
            req.headers["x-forwarded-for"] ||
            "anonymous";

        const result = await limiter.checkLimit(identifier, action);

        // Set rate limit headers
        res.set({
            "X-RateLimit-Limit": result.total,
            "X-RateLimit-Remaining": result.remaining,
            "X-RateLimit-Reset": Math.ceil(result.resetAt / 1000),
        });

        if (!result.allowed) {
            res.set("Retry-After", result.retryAfter);
            return res.status(429).json({
                success: false,
                error: "TooManyRequests",
                message: "Rate limit exceeded. Please try again later.",
                retryAfter: result.retryAfter,
            });
        }

        next();
    };
};

/**
 * Create a rate limiter instance with default settings
 */
const createRateLimiter = (options = {}) => {
    return new RateLimiter(options);
};

module.exports = {
    RateLimiter,
    rateLimitMiddleware,
    createRateLimiter,
};
