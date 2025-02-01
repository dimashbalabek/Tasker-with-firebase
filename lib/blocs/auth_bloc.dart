import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
part "auth_event.dart";
part "auth_state.dart";



/// BLoC для аутентификации
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async{
      final email = event.email;
      final password = event.password;

      if (password.length < 6) {
        return emit(AuthFailure(error: "Password cannot be less than 6 chracters!"));
      }
      try {
        final UserCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: email,
          password: password
          );  
          print(UserCredential);

          emit(AuthSuccess(success: "Successfuly logged in"));

          return Future.delayed(const Duration(seconds: 1), ()=> emit(AuthLoading()));
          
          } on FirebaseAuthException catch (e) {
            print(e.message);
    }
    },
    );

    on<AuthSignUpRequested>((event, emit) async{
      final email = event.email;
      final password = event.password;

      if (password.length < 6) {
        return emit(AuthFailure(error: "Password cannot be less than 6 chracters!"));
      }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email,
              password: password);
      print(userCredential);

      emit(AuthSuccess(success: "Successfuly Signed up!"));
          
      return Future.delayed(const Duration(seconds: 1), ()=> emit(AuthLoading()));


    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  },
  );
  }
}