import 'package:study_circle/utils/constants.dart';

/// Validation utilities for form inputs
class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'Name must be less than ${AppConstants.maxNameLength} characters';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate group members count
  static String? validateGroupMembers(String? value) {
    if (value == null || value.isEmpty) {
      return 'Maximum members is required';
    }

    final num = int.tryParse(value);
    if (num == null) {
      return 'Please enter a valid number';
    }

    if (num < AppConstants.minGroupMembers ||
        num > AppConstants.maxGroupMembers) {
      return 'Members must be between ${AppConstants.minGroupMembers} and ${AppConstants.maxGroupMembers}';
    }

    return null;
  }

  /// Validate description length
  static String? validateDescription(String? value) {
    if (value != null && value.length > AppConstants.maxDescriptionLength) {
      return 'Description must be less than ${AppConstants.maxDescriptionLength} characters';
    }
    return null;
  }

  /// Validate semester/year
  static String? validateSemesterYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Semester/Year is required';
    }

    final num = int.tryParse(value);
    if (num == null) {
      return 'Please enter a valid number';
    }

    if (num < 1 || num > 8) {
      return 'Semester must be between 1 and 8';
    }

    return null;
  }

  /// Validate phone number (optional)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }
}
