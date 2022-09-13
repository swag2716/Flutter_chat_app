import 'package:chat_app/models/firebaseHelpers.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/complete_profile.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:chat_app/pages/login_page.dart';
// import 'package:chat_app/pages/signUp_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser!=null){
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel!=null){
      runApp(MaterialApp(home: HomePage(userModel: thisUserModel, firebaseUser: currentUser)));
    }
    else{
      runApp(const MaterialApp(home: LoginPage()));
    }
  } else{
    runApp(const MaterialApp(home: LoginPage()));
  }
}
