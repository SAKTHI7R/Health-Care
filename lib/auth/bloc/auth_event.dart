abstract class AuthEvent {}

class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  EmailSignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  SignUpRequested(this.email, this.password);
}

class GoogleSignInRequested extends AuthEvent {}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  ResetPasswordRequested(this.email);
}

class SignOutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
