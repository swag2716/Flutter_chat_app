import 'dart:developer';
import 'dart:io';
import 'package:chat_app/models/dialog_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({super.key, required this.userModel, required this.firebaseUser});


  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  File? imageFile;
  TextEditingController fullnameController = TextEditingController();

  void cropImage(XFile file) async{
    var croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 10,
    );
    if(croppedImage!=null){
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void selectImage(ImageSource source) async{
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if(pickedFile != null){
      cropImage(pickedFile);
    }
  }
  

  void showPhotoOptions(){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Upload Profile Picture"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
        ListTile(
          onTap: () {
            Navigator.pop(context);
            selectImage(ImageSource.gallery);
          },
          leading: const Icon(Icons.photo_album),
          title: const Text("Select from Gallery"),
        ),

        ListTile(
          onTap: () {
            Navigator.pop(context);
            selectImage(ImageSource.camera);
          },
          leading: const Icon(Icons.camera),
          title: const Text("Take a photo") ,
        )

      ]),
    ));
  }

  void checkValues(){
    String fullname = fullnameController.text.trim();

    if(fullname == ""|| imageFile == null){
      DialogHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }
    else{
      uploadData();
      log("Data uploading");
    }
  }

  void uploadData() async{
    DialogHelper.showLoadingDialog(context, "Uploading Image...");
    UploadTask uploadTask = FirebaseStorage.instance.ref("profilepictures").child(widget.userModel.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullnameController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance.collection("users").doc(widget.userModel.uid).set(widget.userModel.toMap()).then((value){
      log("Data Uploaded");
    });
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: (imageFile!=null)?FileImage(imageFile!):null,
                  child: (imageFile==null)?const Icon(
                        Icons.person,
                        size: 50,
                      ):null,
                ),
              ),
              TextField(
                controller: fullnameController,
                decoration: const InputDecoration(
                  hintText: "Enter Full Name",
                  labelText: "Full Name",
                ),
              ),
              const SizedBox(height: 30,),
              CupertinoButton(
                color: Colors.blue,
                child: const Text("Submit"),
                onPressed: () {
                  checkValues();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

