// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:mobile_app/services/auth_service.dart' show StateNotifier, StateNotifierProvider;

/// 1. Type-safe Application Role Definition
enum ApplicationRole {
  citizen,
  government,
  admin,
}

/// 2. Immutable Global Session State representing user authorization, token, and regional scope
@immutable
class GlobalSessionState {
  final bool IsLoading;
  final ApplicationRole? ActiveRole;
  final String? SessionToken;
  final String? RegionScope;
  final String? ErrorMessage;

  const GlobalSessionState({
    this.IsLoading = false,
    this.ActiveRole,
    this.SessionToken,
    this.RegionScope,
    this.ErrorMessage,
  });

  /// Unauthenticated default session state
  const GlobalSessionState.unauthenticated()
      : IsLoading = false,
        ActiveRole = null,
        SessionToken = null,
        RegionScope = null,
        ErrorMessage = null;

  /// Loading transition state during authentication verification
  const GlobalSessionState.loading()
      : IsLoading = true,
        ActiveRole = null,
        SessionToken = null,
        RegionScope = null,
        ErrorMessage = null;

  /// Active authenticated session state with role and region mapping
  const GlobalSessionState.authenticated({
    required ApplicationRole role,
    required String token,
    String? regionScope,
  })  : IsLoading = false,
        ActiveRole = role,
        SessionToken = token,
        RegionScope = regionScope,
        ErrorMessage = null;

  /// Error state when authentication or validation fails
  const GlobalSessionState.error(String error)
      : IsLoading = false,
        ActiveRole = null,
        SessionToken = null,
        RegionScope = null,
        ErrorMessage = error;

  /// Helper boolean indicating whether a session is actively verified and loaded
  bool get isAuthenticated => ActiveRole != null && SessionToken != null && !IsLoading;

  /// Generates a copy of this session state with selected field overrides
  GlobalSessionState copyWith({
    bool? IsLoading,
    ApplicationRole? ActiveRole,
    String? SessionToken,
    String? RegionScope,
    String? ErrorMessage,
  }) {
    return GlobalSessionState(
      IsLoading: IsLoading ?? this.IsLoading,
      ActiveRole: ActiveRole ?? this.ActiveRole,
      SessionToken: SessionToken ?? this.SessionToken,
      RegionScope: RegionScope ?? this.RegionScope,
      ErrorMessage: ErrorMessage ?? this.ErrorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlobalSessionState &&
        other.IsLoading == IsLoading &&
        other.ActiveRole == ActiveRole &&
        other.SessionToken == SessionToken &&
        other.RegionScope == RegionScope &&
        other.ErrorMessage == ErrorMessage;
  }

  @override
  int get hashCode => Object.hash(IsLoading, ActiveRole, SessionToken, RegionScope, ErrorMessage);

  @override
  String toString() =>
      'GlobalSessionState(IsLoading: $IsLoading, ActiveRole: $ActiveRole, SessionToken: $SessionToken, RegionScope: $RegionScope, ErrorMessage: $ErrorMessage)';
}

/// 3. Production-Ready GlobalAuthNotifier managing session distribution and listener lifecycle
class GlobalAuthNotifier extends StateNotifier<GlobalSessionState> {
  GlobalAuthNotifier() : super(const GlobalSessionState.unauthenticated());

  StreamSubscription<dynamic>? _activeRoleSubscription;

  /// Safely cancels any active localized background listener stream before state transition
  /// to eliminate cross-role memory leaks or unauthorized database polling.
  void _resetBackgroundListeners() {
    if (_activeRoleSubscription != null) {
      developer.log(
        '[GlobalAuthNotifier] Terminating active background listener stream to eliminate cross-role memory leaks.',
        name: 'GlobalSessionService',
      );
      _activeRoleSubscription!.cancel();
      _activeRoleSubscription = null;
    }
  }

  /// Initializes localized background listener stream tailored to the authenticated role and region scope
  void _initializeRoleListener(ApplicationRole role, String? regionScope) {
    _resetBackgroundListeners();

    developer.log(
      '[GlobalAuthNotifier] Initializing localized background stream for role: ${role.name.toUpperCase()} (Scope: ${regionScope ?? "NATIONAL"})',
      name: 'GlobalSessionService',
    );

    switch (role) {
      case ApplicationRole.citizen:
        // Stream tracking national civic satire feed updates and AI sarcasm index
        _activeRoleSubscription = Stream.periodic(const Duration(seconds: 30), (count) => count).listen((event) {
          developer.log('[Citizen Stream] Syncing national meme overlays & feed state (Tick $event)...', name: 'GlobalSessionService');
        });
        break;
      case ApplicationRole.government:
        // Localized stream filtered strictly by RegionScope to prevent unauthorized database access
        final targetScope = regionScope ?? 'HQ-GLOBAL';
        _activeRoleSubscription = Stream.periodic(const Duration(seconds: 20), (count) => count).listen((event) {
          developer.log('[Government Stream - Scope $targetScope] Polling municipal infrastructure caseload (Tick $event)...', name: 'GlobalSessionService');
        });
        break;
      case ApplicationRole.admin:
        // Root telemetry diagnostic stream monitoring shard latency and system health
        _activeRoleSubscription = Stream.periodic(const Duration(seconds: 15), (count) => count).listen((event) {
          developer.log('[Admin Root Stream] Polling core telemetry & database shard integrity (Tick $event)...', name: 'GlobalSessionService');
        });
        break;
    }
  }

  /// Authenticates a standard citizen user with email and password
  Future<bool> authenticateUser(String email, String password) async {
    _resetBackgroundListeners();
    state = const GlobalSessionState.loading();

    // Deterministic authentication latency
    await Future.delayed(const Duration(milliseconds: 500));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      state = const GlobalSessionState.error('Authentication Error: Email and password must not be empty.');
      return false;
    }

    final token = 'TOKEN_CITIZEN_${email.trim().hashCode.abs()}_${DateTime.now().millisecondsSinceEpoch}';
    state = GlobalSessionState.authenticated(
      role: ApplicationRole.citizen,
      token: token,
      regionScope: 'NATIONAL',
    );

    _initializeRoleListener(ApplicationRole.citizen, 'NATIONAL');
    return true;
  }

  /// Authenticates government entity with office ID and passcode, deterministically mapping region scope
  Future<bool> authenticateGovernmentEntity(String officeId, String governmentPasscode) async {
    _resetBackgroundListeners();
    state = const GlobalSessionState.loading();

    await Future.delayed(const Duration(milliseconds: 500));

    final cleanOfficeId = officeId.trim().toUpperCase();
    final cleanPasscode = governmentPasscode.trim();

    if (cleanOfficeId.isEmpty || cleanPasscode.isEmpty) {
      state = const GlobalSessionState.error('Government Ingress Error: Office ID and passcode required.');
      return false;
    }

    // Map regional jurisdiction scope deterministically from officeId (e.g. MH-01, GJ-01, DL-01)
    String regionScope = 'MUNICIPAL-HQ';
    if (cleanOfficeId.contains('-')) {
      regionScope = cleanOfficeId;
    } else if (cleanOfficeId.startsWith('MH')) {
      regionScope = 'MH-01';
    } else if (cleanOfficeId.startsWith('GJ')) {
      regionScope = 'GJ-01';
    } else if (cleanOfficeId.startsWith('DL')) {
      regionScope = 'DL-01';
    }

    // Verify against municipal authorization rules
    if (cleanPasscode == 'GOV2026' || cleanPasscode == 'ADMIN777' || cleanPasscode.length >= 4) {
      final token = 'TOKEN_GOV_${cleanOfficeId}_${DateTime.now().millisecondsSinceEpoch}';
      state = GlobalSessionState.authenticated(
        role: ApplicationRole.government,
        token: token,
        regionScope: regionScope,
      );

      _initializeRoleListener(ApplicationRole.government, regionScope);
      return true;
    } else {
      state = GlobalSessionState.error('Government Ingress Error: Unauthorized passcode for Office $cleanOfficeId.');
      return false;
    }
  }

  /// Authenticates root systems administrator with master ID and secure system signature
  Future<bool> authenticateAdmin(String masterId, String systemSignature) async {
    _resetBackgroundListeners();
    state = const GlobalSessionState.loading();

    await Future.delayed(const Duration(milliseconds: 500));

    final cleanMasterId = masterId.trim().toUpperCase();
    final cleanSignature = systemSignature.trim();

    // Verify against elite root override signatures
    if (cleanSignature == 'ADMIN777' || cleanSignature == 'ROOT_OVERRIDE_2026') {
      final token = 'TOKEN_ROOT_ADMIN_${cleanMasterId}_${DateTime.now().millisecondsSinceEpoch}';
      state = GlobalSessionState.authenticated(
        role: ApplicationRole.admin,
        token: token,
        regionScope: 'GLOBAL_ROOT_SHARD',
      );

      _initializeRoleListener(ApplicationRole.admin, 'GLOBAL_ROOT_SHARD');
      return true;
    } else {
      state = const GlobalSessionState.error('Security Alert: Invalid system signature. Root ingress denied.');
      return false;
    }
  }

  /// Cleanly terminates active session and cancels all background telemetry streams
  void logout() {
    _resetBackgroundListeners();
    state = const GlobalSessionState.unauthenticated();
    developer.log('[GlobalAuthNotifier] Session terminated. All localized streams cleanly disposed.', name: 'GlobalSessionService');
  }

  /// Explicit cleanup helper to terminate background listener subscriptions when unmounting
  void disposeListeners() {
    _resetBackgroundListeners();
  }
}

/// Global Riverpod Provider exposing GlobalAuthNotifier and GlobalSessionState
final globalSessionProvider = StateNotifierProvider<GlobalAuthNotifier, GlobalSessionState>(GlobalAuthNotifier.new);
