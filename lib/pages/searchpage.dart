import 'dart:ffi';

import 'package:chat_app/pages/chatroompage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/usermodel.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Container(
          child: Column(children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Email Address",
              ),
            ),
            const SizedBox(height: 20,),
            CupertinoButton(
                color: Colors.blue,
                onPressed: () {
                  setState(() {
                    
                  });
                },
                child: const Text("Search")),
                const SizedBox(height: 20,),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("users").where("email", isEqualTo: searchController.text).where("email", isNotEqualTo: widget.userModel.email).snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.active){
                      if(snapshot.hasData){
                        QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                        if(dataSnapshot.docs.length>0){
                          Map<String, dynamic> userMap = dataSnapshot.docs[0].data() as Map<String, dynamic>;
                          UserModel searchedUser = UserModel.fromMap(userMap);
                          return ListTile(
                            onTap: (){
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatRoomPage()));
                            },
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(searchedUser.profilepic!),
                            ),
                            title: Text(searchedUser.fullname!),
                            subtitle: Text(searchedUser.email!),
                            trailing: const Icon(Icons.arrow_right),
                          );
                        }
                        else{
                          return const Text("No results found");
                        }
                      }
                      else if(snapshot.hasError){
                        return const Text("An error Occured");
                      }
                      else{
                        return const Text("No results Found");
                      }
                    }else{
                      return const CircularProgressIndicator();
                    }
                  }
                ),
          ]),
        ),
      )),
    );
  }
}
