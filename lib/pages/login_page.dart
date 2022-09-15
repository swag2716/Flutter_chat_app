import 'package:chat_app/models/dialog_helper.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/signUp_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email==""||password==""){
      DialogHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }

    else{
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;
    DialogHelper.showLoadingDialog(context, "Logging In...");
    try{
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      DialogHelper.showAlertDialog(context, "An error occured", ex.message.toString());
    }
    if(credential!=null){
      String uid = credential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String, dynamic>);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(userModel: userModel, firebaseUser: credential!.user!,)));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Chat App",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 35,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter Email",
                      labelText: "Email",
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Enter Password",
                      labelText: "Password",
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                      onPressed: () {
                        checkValues();
                      },
                      color: Colors.blue,
                      child: const Text("Log In")),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(fontSize: 16),
        ),
        CupertinoButton(
          child: const Text("Sign Up"),
          onPressed: () {
           Navigator.push(context, MaterialPageRoute(builder: ((context) => const SignUpPage())));
          },
        ),
      ]),
    );
  }
}
