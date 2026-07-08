import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User Role hierarchy for Role-Based Access Control (RBAC) in StreetVoice.
enum UserRole {
  citizen,
  government,
  admin,
}

/// Immutable authentication and RBAC session state for StreetVoice.
@immutable
class GlobalAuthState {
  final UserRole? role;
  final bool isAuthenticated;
  final String? email;
  final String? rtoScope;
  final String? errorMessage;

  const GlobalAuthState({
    this.role,
    this.isAuthenticated = false,
    this.email,
    this.rtoScope,
    this.errorMessage,
  });

  /// Initial unauthenticated session state factory constructor.
  factory GlobalAuthState.initial() => const GlobalAuthState(
        role: null,
        isAuthenticated: false,
        email: null,
        rtoScope: null,
        errorMessage: null,
      );

  /// Creates a copy of [GlobalAuthState] with optional parameter overrides.
  GlobalAuthState copyWith({
    UserRole? role,
    bool? isAuthenticated,
    String? email,
    String? rtoScope,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GlobalAuthState(
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      rtoScope: rtoScope ?? this.rtoScope,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Riverpod 2.0+ [Notifier] managing global authentication state,
/// RBAC role assignments, and RTO jurisdictional scoping.
class GlobalAuthNotifier extends Notifier<GlobalAuthState> {
  @override
  GlobalAuthState build() {
    return GlobalAuthState.initial();
  }

  /// Authenticates user based on email domain pattern and sets appropriate RBAC role.
  /// Examples:
  /// - `@streetvoice.gov` -> [UserRole.admin]
  /// - `@municipal.gov.in` -> [UserRole.government]
  /// - Standard citizen emails -> [UserRole.citizen]
  void login(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.isEmpty || password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Email and password are required.',
      );
      return;
    }

    UserRole assignedRole;
    String defaultRtoScope = 'MH-01';

    if (cleanEmail.endsWith('@streetvoice.gov') ||
        cleanEmail == 'admin@streetvoice.gov') {
      assignedRole = UserRole.admin;
      defaultRtoScope = 'NATIONAL';
    } else if (cleanEmail.endsWith('@municipal.gov.in') ||
        cleanEmail.endsWith('@rto.gov.in') ||
        cleanEmail.contains('gov')) {
      assignedRole = UserRole.government;
      defaultRtoScope = 'MH-01';
    } else {
      assignedRole = UserRole.citizen;
      defaultRtoScope = 'MH-01';
    }

    state = GlobalAuthState(
      role: assignedRole,
      isAuthenticated: true,
      email: cleanEmail,
      rtoScope: defaultRtoScope,
      errorMessage: null,
    );
  }

  /// Registers a new citizen account and grants an active session.
  void registerCitizen({
    required String name,
    required String email,
    required String rtoScope,
    required String password,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanRto = rtoScope.trim().toUpperCase();

    if (cleanEmail.isEmpty || password.isEmpty || cleanRto.isEmpty) {
      state = state.copyWith(
        errorMessage: 'All fields are required for citizen registration.',
      );
      return;
    }

    state = GlobalAuthState(
      role: UserRole.citizen,
      isAuthenticated: true,
      email: cleanEmail,
      rtoScope: cleanRto,
      errorMessage: null,
    );
  }

  /// Registers a new government entity or municipal ingress account.
  void registerGovernment({
    required String officeName,
    required String email,
    required String rtoScope,
    required String password,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanRto = rtoScope.trim().toUpperCase();

    if (cleanEmail.isEmpty || password.isEmpty || cleanRto.isEmpty) {
      state = state.copyWith(
        errorMessage: 'All fields are required for government entity registration.',
      );
      return;
    }

    state = GlobalAuthState(
      role: UserRole.government,
      isAuthenticated: true,
      email: cleanEmail,
      rtoScope: cleanRto,
      errorMessage: null,
    );
  }

  /// Updates the active session's regional RTO jurisdiction scope.
  void updateRtoScope(String newRtoScope) {
    state = state.copyWith(rtoScope: newRtoScope.trim().toUpperCase());
  }

  /// Resets session to initial unauthenticated state.
  void logout() {
    state = GlobalAuthState.initial();
  }
}

/// Global Riverpod Provider exposing [GlobalAuthNotifier] and [GlobalAuthState].
final globalAuthProvider =
    NotifierProvider<GlobalAuthNotifier, GlobalAuthState>(
  GlobalAuthNotifier.new,
);
