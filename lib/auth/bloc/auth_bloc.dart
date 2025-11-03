import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _authRepository.authenticate(
        login: event.email,
        password: event.password,
      );

      // Check if authentication was successful
      if (response.containsKey('result') && response['result'] != null) {
        emit(AuthAuthenticated(userData: response['result']));
      } else {
        emit(const AuthError(message: 'Invalid credentials'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthUnauthenticated());
  }
}

