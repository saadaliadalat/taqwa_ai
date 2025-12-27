import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Authentication service wrapping Firebase Auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last active timestamp
      if (credential.user != null) {
        await _updateLastActive(credential.user!.uid);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register with email and password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name if provided
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
      }
      
      // Create user document in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!, displayName: displayName);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in anonymously (guest mode)
  Future<UserCredential> signInAsGuest() async {
    try {
      final credential = await _auth.signInAnonymously();
      
      // Create guest user document
      if (credential.user != null) {
        await _createUserDocument(credential.user!, isGuest: true);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('No user signed in');

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    // Update Firestore document
    await _firestore.collection('users').doc(user.uid).update({
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update user preferences
  Future<void> updatePreferences({
    String? madhhab,
    String? language,
    bool? notificationsEnabled,
    bool? dailyAyahEnabled,
    String? dailyAyahTime,
    bool? darkModeEnabled,
    int? quranFontSize,
    bool? showTranslation,
    String? translationLanguage,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('No user signed in');

    final updates = <String, dynamic>{
      'lastActiveAt': FieldValue.serverTimestamp(),
    };

    final prefUpdates = <String, dynamic>{};
    if (madhhab != null) prefUpdates['madhhab'] = madhhab;
    if (language != null) prefUpdates['language'] = language;
    if (notificationsEnabled != null) prefUpdates['notificationsEnabled'] = notificationsEnabled;
    if (dailyAyahEnabled != null) prefUpdates['dailyAyahEnabled'] = dailyAyahEnabled;
    if (dailyAyahTime != null) prefUpdates['dailyAyahTime'] = dailyAyahTime;
    if (darkModeEnabled != null) prefUpdates['darkModeEnabled'] = darkModeEnabled;
    if (quranFontSize != null) prefUpdates['quranFontSize'] = quranFontSize;
    if (showTranslation != null) prefUpdates['showTranslation'] = showTranslation;
    if (translationLanguage != null) prefUpdates['translationLanguage'] = translationLanguage;

    for (final entry in prefUpdates.entries) {
      updates['preferences.${entry.key}'] = entry.value;
    }

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  /// Stream user data from Firestore
  Stream<UserModel?> streamUserData() {
    final user = currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Convert guest to permanent account
  Future<UserCredential> convertGuestToEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final user = currentUser;
    if (user == null || !user.isAnonymous) {
      throw Exception('No anonymous user to convert');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      final result = await user.linkWithCredential(credential);
      
      // Update user document
      await _firestore.collection('users').doc(user.uid).update({
        'email': email,
        'displayName': displayName,
        'isGuest': false,
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('No user signed in');

    // Delete user data from Firestore
    await _firestore.collection('users').doc(user.uid).delete();
    
    // Delete Firebase Auth account
    await user.delete();
  }

  // ============================================
  // Private Methods
  // ============================================

  /// Create user document in Firestore
  Future<void> _createUserDocument(
    User user, {
    String? displayName,
    bool isGuest = false,
  }) async {
    final now = DateTime.now();
    final userData = UserModel(
      id: user.uid,
      email: user.email,
      displayName: displayName ?? user.displayName,
      isGuest: isGuest,
      photoUrl: user.photoURL,
      createdAt: now,
      lastActiveAt: now,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userData.toFirestore());
  }

  /// Update last active timestamp
  Future<void> _updateLastActive(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
