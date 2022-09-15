import 'package:chat_app/pages/complete_profile.dart';
import 'package:chat_app/models/dialog_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();


  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = cpasswordController.text.trim();

    if(email==""||password==""||cpassword==""){
      DialogHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }

    else if(password!=cpassword){
      DialogHelper.showAlertDialog(context, "Passwords mismatch", "The password you enetred do not match");
    }

    else{
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
  DialogHelper.showLoadingDialog(context, "Creating new account...");
    try{
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      DialogHelper.showAlertDialog(context, "An error occured", ex.message.toString());
    }
    if(credential!=null){
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance.collection("users").doc(uid).set(
        newUser.toMap()
      ).then((value) => print("User Created!"));
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CompleteProfile(userModel: newUser, firebaseUser: credential!.user!)));
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
                  const SizedBox(height: 20,),

                  TextField(
                    controller: cpasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Enter Password",
                      labelText: "Confirm Password",
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                      onPressed: () {
                        checkValues();
                        // Navigator.push(context, MaterialPageRoute(builder: ((context) => CompleteProfile())));
                      },
                      color: Colors.blue,
                      child: const Text("Sign Up")),
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
          "Already have an account?",
          style: TextStyle(fontSize: 16),
        ),
        CupertinoButton(
          child: const Text("Log In"),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: ((context) => const LoginPage())));
          },
        ),
      ]),
    );
  }
}