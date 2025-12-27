/**
 * Authentication Middleware for Taqwa AI Cloud Functions
 * 
 * Validates Firebase Auth tokens and extracts user information
 * for protected endpoints.
 */

const admin = require("firebase-admin");

/**
 * Middleware to validate Firebase Authentication token
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const validateFirebaseToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      error: "Unauthorized",
      message: "Missing or invalid Authorization header. Use 'Bearer <token>'",
    });
  }

  const idToken = authHeader.split("Bearer ")[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    
    // Attach user info to request object
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email || null,
      emailVerified: decodedToken.email_verified || false,
      isAnonymous: decodedToken.provider_id === "anonymous",
      name: decodedToken.name || null,
    };

    next();
  } catch (error) {
    console.error("Token verification failed:", error.message);

    if (error.code === "auth/id-token-expired") {
      return res.status(401).json({
        success: false,
        error: "TokenExpired",
        message: "Authentication token has expired. Please sign in again.",
      });
    }

    if (error.code === "auth/id-token-revoked") {
      return res.status(401).json({
        success: false,
        error: "TokenRevoked",
        message: "Authentication token has been revoked. Please sign in again.",
      });
    }

    return res.status(401).json({
      success: false,
      error: "InvalidToken",
      message: "Invalid authentication token.",
    });
  }
};

/**
 * Optional authentication middleware
 * Allows requests to proceed even without authentication
 * Sets req.user to null if not authenticated
 */
const optionalAuth = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    req.user = null;
    return next();
  }

  const idToken = authHeader.split("Bearer ")[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email || null,
      emailVerified: decodedToken.email_verified || false,
      isAnonymous: decodedToken.provider_id === "anonymous",
      name: decodedToken.name || null,
    };
  } catch (error) {
    console.warn("Optional auth failed:", error.message);
    req.user = null;
  }

  next();
};

/**
 * Middleware to require email verification
 * Must be used after validateFirebaseToken
 */
const requireEmailVerified = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      error: "Unauthorized",
      message: "Authentication required.",
    });
  }

  if (req.user.isAnonymous) {
    // Allow anonymous users to proceed
    return next();
  }

  if (!req.user.emailVerified) {
    return res.status(403).json({
      success: false,
      error: "EmailNotVerified",
      message: "Please verify your email address to access this feature.",
    });
  }

  next();
};

/**
 * Extract user ID from request
 * Useful for callable functions that don't use Express middleware
 * @param {Object} context - Firebase callable context
 * @returns {string|null} User ID or null if not authenticated
 */
const getUserIdFromContext = (context) => {
  if (!context.auth) {
    return null;
  }
  return context.auth.uid;
};

/**
 * Validate that the request is from an authenticated user
 * For use with Firebase callable functions
 * @param {Object} context - Firebase callable context
 * @throws {Error} If user is not authenticated
 */
const requireAuthContext = (context) => {
  if (!context.auth) {
    throw new Error("Authentication required to access this function.");
  }
  return {
    uid: context.auth.uid,
    email: context.auth.token.email || null,
    emailVerified: context.auth.token.email_verified || false,
    isAnonymous: context.auth.token.firebase.sign_in_provider === "anonymous",
  };
};

module.exports = {
  validateFirebaseToken,
  optionalAuth,
  requireEmailVerified,
  getUserIdFromContext,
  requireAuthContext,
};
