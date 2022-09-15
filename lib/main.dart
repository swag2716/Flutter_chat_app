import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

Future<Widget?> isLoggedIn() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser!=null){
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel!=null){
      return HomePage(userModel: thisUserModel, firebaseUser: currentUser);
    }
    else{
      return const LoginPage();
    }
  } else{
    return const LoginPage();
  }
}



void main() async{
  runApp(MaterialApp(home : await isLoggedIn()));
}

