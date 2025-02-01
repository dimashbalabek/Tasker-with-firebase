import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_first_project/firebase_options.dart';
import 'package:flutter/cupertino.dart';

class FireBaseData {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> signOut() async{
   await  _auth.signOut();
  }
}