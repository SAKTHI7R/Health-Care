import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../profile/models/profile_model.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<EmailSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signInWithEmail(event.email, event.password);
        emit(Authenticated(authRepository.currentUser!));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signUpWithEmail(event.email, event.password);
        final user = authRepository.currentUser!;
        final uid = user.uid;

        final profile = ProfileModel(
          name: '',
          email: event.email,
          phone: '',
          photoUrl: '',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(profile.toMap());

        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signInWithGoogle();
        emit(Authenticated(authRepository.currentUser!));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.sendPasswordResetEmail(event.email);
        emit(AuthPasswordResetSent());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignOutRequested>((event, emit) async {
      await authRepository.signOut();
      emit(AuthInitial());
    });
    on<CheckAuthStatus>((event, emit) async {
      final user = authRepository.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthInitial());
      }
    });
  }
}
