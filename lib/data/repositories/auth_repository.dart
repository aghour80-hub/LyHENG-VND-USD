import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_exception.dart';
import '../services/supabase_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isAuthorizedAdmin;
  final String? userEmail;
  final String? userId;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.isAuthorizedAdmin = false,
    this.userEmail,
    this.userId,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isAuthorizedAdmin,
    String? userEmail,
    String? userId,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAuthorizedAdmin: isAuthorizedAdmin ?? this.isAuthorizedAdmin,
      userEmail: userEmail ?? this.userEmail,
      userId: userId ?? this.userId,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final authRepositoryProvider = NotifierProvider<AuthRepository, AuthState>(AuthRepository.new);

class AuthRepository extends Notifier<AuthState> {
  final SupabaseService? _injectedService;

  AuthRepository([this._injectedService]);

  SupabaseService get _supabaseService => _injectedService ?? SupabaseService.instance;

  @override
  AuthState build() {
    _checkInitialAuth();
    return const AuthState();
  }

  Future<void> _checkInitialAuth() async {
    if (!_supabaseService.isConfigured) return;

    final user = _supabaseService.currentAuthUser;
    if (user != null) {
      state = state.copyWith(isLoading: true);
      final isAuthorized = await _supabaseService.verifyAdminStatus(user.id);
      if (isAuthorized) {
        state = AuthState(
          isAuthenticated: true,
          isAuthorizedAdmin: true,
          userId: user.id,
          userEmail: user.email,
        );
      } else {
        await _supabaseService.signOut();
        state = const AuthState();
      }
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Local / Demo mode fallback when Supabase is not configured
    if (!_supabaseService.isConfigured) {
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedPassword = password.trim();
      if ((normalizedEmail == 'lyheng@lyheng.com' || normalizedEmail == 'lyheng') &&
          (normalizedPassword == 'Lyheng168' || normalizedPassword == 'lyheng168')) {
        state = const AuthState(
          isAuthenticated: true,
          isAuthorizedAdmin: true,
          userId: 'lyheng-demo-admin-uuid',
          userEmail: 'lyheng@lyheng.com',
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Tên đăng nhập hoặc mật khẩu quản trị không chính xác.',
        );
        return false;
      }
    }

    try {
      final response = await _supabaseService.signInWithEmailPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthExceptionApp('Authentication failed: No user returned.');
      }

      // Check Admin Authorization via database function
      final isAuthorized = await _supabaseService.verifyAdminStatus(user.id);
      if (!isAuthorized) {
        await _supabaseService.signOut();
        throw const UnauthorizedException(
          'Access denied. This account does not have Admin authorization in admin_users.',
        );
      }

      state = AuthState(
        isAuthenticated: true,
        isAuthorizedAdmin: true,
        userId: user.id,
        userEmail: user.email,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _supabaseService.signOut();
    state = const AuthState();
  }
}
