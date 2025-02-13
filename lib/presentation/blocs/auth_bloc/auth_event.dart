part of "auth_bloc.dart";
sealed class AuthEvent {
  
}

final class AuthLoginRequested extends AuthEvent{
  final String email;
  final String password;

  
  AuthLoginRequested({
    required this.email,
    required this.password,
  });
}

final class AuthSignUpRequested extends AuthEvent{
  final String email;
  final String password;
  final String userName;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.userName
  });
}

