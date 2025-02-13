import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part "auth_event.dart";
part "auth_state.dart";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    final email = event.email;
    final password = event.password;

    if (password.length < 6) {
      emit(AuthFailure(error: "Password cannot be less than 6 characters!"));
      return;
    }

    try {
      emit(AuthLoading());

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        emit(AuthFailure(error: "User not found!"));
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        emit(AuthFailure(error: "User data not found in Firestore!"));
        return;
      }

      final userData = userDoc.data();
      print("User data loaded: $userData");

      emit(AuthSuccess(success: "Successfully logged in"));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(error: e.message ?? "An error occurred"));
    }
  }

  Future<void> _onSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    final email = event.email;
    final password = event.password;
    final userName = event.userName; // Получаем userName из события

    if (password.length < 6) {
      emit(AuthFailure(error: "Password cannot be less than 6 characters!"));
      return;
    }

    try {
      emit(AuthLoading());

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        emit(AuthFailure(error: "User registration failed!"));
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': Timestamp.now(),
        'userName': userName, 
      }, SetOptions(merge: true));

      emit(AuthSuccess(success: "Successfully signed up!"));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(error: e.message ?? "An error occurred"));
    }
  }
}
