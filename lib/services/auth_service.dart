import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_circle/utils/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Attempting to sign in user: $email');
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      AppLogger.info('Sign in successful for user: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Sign in failed', e, StackTrace.current);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Unexpected sign in error', e, StackTrace.current);
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Attempting to register user: $email');
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      AppLogger.info('Registration successful for user: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Registration failed', e, StackTrace.current);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Unexpected registration error', e, StackTrace.current);
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      AppLogger.info('User signing out: ${currentUser?.uid}');
      await _auth.signOut();
      AppLogger.info('Sign out successful');
    } catch (e, stackTrace) {
      AppLogger.error('Sign out failed', e, stackTrace);
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.info('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email.trim());
      AppLogger.info('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password reset failed', e, StackTrace.current);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Unexpected password reset error', e, StackTrace.current);
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw 'No user is currently signed in.';
      
      AppLogger.warning('Deleting user account: ${user.uid}');
      await user.delete();
      AppLogger.info('Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Account deletion failed', e, StackTrace.current);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Unexpected account deletion error', e, StackTrace.current);
      throw 'Failed to delete account. Please try again.';
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = currentUser;
      if (user == null) throw 'No user is currently signed in.';
      
      AppLogger.info('Updating email for user: ${user.uid}');
      await user.verifyBeforeUpdateEmail(newEmail.trim());
      AppLogger.info('Verification email sent to: $newEmail');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Email update failed', e, StackTrace.current);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Unexpected email update error', e, StackTrace.current);
      throw 'Failed to update email. Please try again.';
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw 'No user is currently signed in.';
      
      AppLogger.info('Updating password for user: ${user.uid}');
      await user.updatePassword(newPassword);
      AppLogger.info('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password update failed', e, StackTrace.current);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Unexpected password update error', e, StackTrace.current);
      throw 'Failed to update password. Please try again.';
    }
  }

  // Reauthenticate user (required for sensitive operations)
  Future<void> reauthenticate(String password) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw 'No user is currently signed in.';
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      AppLogger.info('Reauthenticating user: ${user.uid}');
      await user.reauthenticateWithCredential(credential);
      AppLogger.info('Reauthentication successful');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Reauthentication failed', e, StackTrace.current);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Unexpected reauthentication error', e, StackTrace.current);
      throw 'Failed to verify credentials. Please try again.';
    }
  }

  // Handle Firebase Auth exceptions with user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
