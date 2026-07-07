import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/views/admin_panel_screen.dart';

/// Riverpod 3 compatibility bridge for StateNotifier pattern
abstract class StateNotifier<T> extends Notifier<T> {
  final T _initialState;
  StateNotifier(this._initialState);

  @override
  T build() => _initialState;
}

/// Compatibility typedef for StateNotifierProvider in Riverpod 3
typedef StateNotifierProvider<NotifierT extends Notifier<ValueT>, ValueT> = NotifierProvider<NotifierT, ValueT>;

/// 1. Role-Based Access Control (RBAC) User Roles
enum UserRole {
  citizen,
  government,
  admin,
}

/// Custom exception thrown when Role-Based validation fails
class AuthValidationException implements Exception {
  final String message;
  const AuthValidationException(this.message);

  @override
  String toString() => message;
}

/// 2. Immutable state class representing authentication status and role access
@immutable
class AuthState {
  final UserRole? role;
  final bool isAuthenticated;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.role,
    this.isAuthenticated = false,
    this.token,
    this.errorMessage,
  });

  /// Factory constructor for unauthenticated initial state
  const AuthState.unauthenticated()
      : role = null,
        isAuthenticated = false,
        token = null,
        errorMessage = null;

  /// Constructor for authenticated state
  AuthState.authenticated({
    required UserRole role,
    String? token,
  })  : role = role,
        isAuthenticated = true,
        token = token ?? 'TOKEN_${role.name.toUpperCase()}_999',
        errorMessage = null;

  /// Factory constructor for error state
  const AuthState.error(String message)
      : role = null,
        isAuthenticated = false,
        token = null,
        errorMessage = message;

  /// Creates a copy of this AuthState with the given fields replaced
  AuthState copyWith({
    UserRole? role,
    bool? isAuthenticated,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.role == role &&
        other.isAuthenticated == isAuthenticated &&
        other.token == token &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(role, isAuthenticated, token, errorMessage);

  @override
  String toString() =>
      'AuthState(role: $role, isAuthenticated: $isAuthenticated, token: $token, errorMessage: $errorMessage)';
}

/// 3. AuthNotifier extending `StateNotifier<AuthState>` initializing as unauthenticated
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.unauthenticated());

  /// Hardcoded backdoor passcode for Admin authentication
  static const String adminBackdoorPasscode = 'ADMIN777';

  /// 4. Authenticates a user based on role and masterKey.
  /// For admin role: verifies against 'ADMIN777'. If correct, updates state and optionally
  /// navigates to Admin Panel layout if [context] is provided. Otherwise throws validation error.
  /// For citizen/government: allows instant authentication for smooth presentation bypass.
  bool loginWithRole(UserRole role, {String masterKey = '', BuildContext? context}) {
    // Ensure clean state transition by handling sign-out loops cleanly before login
    if (state.isAuthenticated || state.role != null) {
      logout();
    }

    if (role == UserRole.admin) {
      // Verify admin master key equals backdoor passcode
      if (masterKey.trim() == adminBackdoorPasscode) {
        state = AuthState.authenticated(
          role: UserRole.admin,
          token: 'ADMIN_SECURE_TOKEN_777',
        );

        // If context is provided, route directly to Admin Panel layout
        if (context != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
          );
        }
        return true;
      } else {
        final errorMsg = 'Validation Error: Invalid Admin Master Key ($masterKey). Access Denied.';
        state = AuthState.error(errorMsg);
        throw AuthValidationException(errorMsg);
      }
    } else {
      // For citizen and government variants, allow instant authentication for smooth presentation bypass
      state = AuthState.authenticated(
        role: role,
        token: role == UserRole.government ? 'GOV_AUTH_BYPASS_TOKEN' : 'CITIZEN_AUTH_BYPASS_TOKEN',
      );
      return true;
    }
  }

  /// Signs out the user and cleanly breaks any sign-out loops or redundant re-renders
  void logout() {
    if (!state.isAuthenticated && state.role == null && state.errorMessage == null && state.token == null) {
      // State is already cleanly unauthenticated; return early to prevent sign-out loops
      return;
    }
    state = const AuthState.unauthenticated();
  }
}

/// Global Riverpod StateNotifierProvider exposing AuthNotifier and AuthState
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
