import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/hive_service.dart';
import '../models/user_model.dart';
import 'shared_providers.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Firebase auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      
      final authService = ref.read(authServiceProvider);
      return await authService.getUserData();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// User data stream provider
final userDataStreamProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.streamUserData();
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final HiveService _hiveService;

  AuthNotifier(this._authService, this._hiveService) : super(const AuthState());

  /// Sign in with email
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.signInWithEmail(email: email, password: password);
      
      // Save user data locally
      final userData = await _authService.getUserData();
      if (userData != null) {
        await _hiveService.saveUser(userData.toFirestore());
      }
      
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Register with email
  Future<void> registerWithEmail(String email, String password, {String? displayName}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      // Save user data locally
      final userData = await _authService.getUserData();
      if (userData != null) {
        await _hiveService.saveUser(userData.toFirestore());
      }
      
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sign in as guest
  Future<void> signInAsGuest() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.signInAsGuest();
      
      // Create guest user locally
      final guestUser = UserModel.guest();
      await _hiveService.saveUser(guestUser.toFirestore());
      
      state = state.copyWith(isLoading: false, isAuthenticated: true, isGuest: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.signOut();
      await _hiveService.clearUser();
      
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false, passwordResetSent: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Convert guest to permanent account
  Future<void> convertGuestAccount(String email, String password, {String? displayName}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.convertGuestToEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      // Update local user data
      final userData = await _authService.getUserData();
      if (userData != null) {
        await _hiveService.saveUser(userData.toFirestore());
      }
      
      state = state.copyWith(isLoading: false, isGuest: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final bool isGuest;
  final bool passwordResetSent;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.isGuest = false,
    this.passwordResetSent = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? isGuest,
    bool? passwordResetSent,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGuest: isGuest ?? this.isGuest,
      passwordResetSent: passwordResetSent ?? this.passwordResetSent,
      error: error,
    );
  }
}

/// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthNotifier(authService, hiveService);
});
