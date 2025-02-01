import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_first_project/blocs/auth_bloc.dart';
import 'package:firebase_first_project/home_page.dart';
import 'package:firebase_first_project/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      );
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Future<void> createUserWithEmailAndPassword() async {
  //   try {
  //     final userCredential = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(
  //             email: emailController.text.trim(),
  //             password: passwordController.text.trim());
  //     print(userCredential);
  //   } on FirebaseAuthException catch (e) {
  //     print(e.message);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }

          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.success)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {

              if (state is AuthSuccess) {
                Center(
                  child: CircularProgressIndicator(
                  color: Colors.purple, 
                  strokeWidth: 12.0,  
            ),
                );
              }
          
              if (state is AuthLoading) {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ));
            });
              }

              return Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign Up.',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        context.read<AuthBloc>().add(AuthSignUpRequested(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim()));
                        // await createUserWithEmailAndPassword();
                      },
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, LoginPage.route());
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
