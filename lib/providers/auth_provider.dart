import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_circle/models/user_model.dart';
import 'package:study_circle/services/auth_service.dart';
import 'package:study_circle/services/firestore_service.dart';
import 'package:study_circle/utils/logger.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, authenticating }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.uninitialized;
  User? _firebaseUser;
  UserModel? _userModel;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.authenticating;

  AuthProvider() {
    _init();
  }

  // Initialize auth state listener
  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _status = AuthStatus.unauthenticated;
        _userModel = null;
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();

      final userData = await _firestoreService.getUserById(uid);
      
      if (userData != null) {
        _userModel = userData;
        _status = AuthStatus.authenticated;
        AppLogger.info('User data loaded: ${userData.name}');
        
        // Auto-sync stats for existing users if needed (runs in background)
        _ensureUserStatsExist(uid);
      } else {
        // User exists in Auth but not in Firestore (incomplete registration)
        _status = AuthStatus.unauthenticated;
        AppLogger.warning('User exists in Auth but not in Firestore');
      }
      
      _errorMessage = null;
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load user data', e, stackTrace);
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Failed to load user data';
      notifyListeners();
    }
  }

  // Ensure user stats exist (runs in background, doesn't block login)
  Future<void> _ensureUserStatsExist(String uid) async {
    try {
      final stats = await _firestoreService.getUserStats(uid);
      if (stats == null || (stats.totalGroupsJoined == 0 && 
          stats.totalGroupsCreated == 0 && 
          stats.totalSessionsAttended == 0 &&
          _userModel != null &&
          (_userModel!.joinedGroupIds.isNotEmpty || _userModel!.createdGroupIds.isNotEmpty))) {
        // Stats don't exist or are empty but user has activity - sync from database
        AppLogger.info('Auto-syncing user stats for: $uid');
        await _firestoreService.syncUserStatsFromDatabase(uid);
      }
    } catch (e, stackTrace) {
      // Don't block login if stats sync fails
      AppLogger.error('Failed to ensure user stats exist', e, stackTrace);
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        AppLogger.info('Sign in successful');
        return true;
      }

      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Sign in failed';
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      AppLogger.error('Sign in error', e, StackTrace.current);
      return false;
    }
  }

  // Register with email and password
  Future<User?> register(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        AppLogger.info('Registration successful');
        return user;
      }

      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Registration failed';
      notifyListeners();
      return null;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      AppLogger.error('Registration error', e, StackTrace.current);
      return null;
    }
  }

  // Create user profile in Firestore
  Future<bool> createUserProfile(UserModel user) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.createOrUpdateUser(user);
      _userModel = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      
      AppLogger.info('User profile created successfully');
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      AppLogger.error('Failed to create user profile', e, StackTrace.current);
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      await _firestoreService.createOrUpdateUser(updatedUser);
      _userModel = updatedUser;
      notifyListeners();
      AppLogger.info('User profile updated successfully');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      AppLogger.error('Failed to update user profile', e, StackTrace.current);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _status = AuthStatus.unauthenticated;
      _userModel = null;
      _firebaseUser = null;
      _errorMessage = null;
      notifyListeners();
      AppLogger.info('User signed out');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      AppLogger.error('Sign out error', e, StackTrace.current);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      AppLogger.info('Password reset email sent');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      AppLogger.error('Password reset error', e, StackTrace.current);
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reload current user data
  Future<void> reloadUserData() async {
    if (_firebaseUser != null) {
      await _loadUserData(_firebaseUser!.uid);
    }
  }
}
