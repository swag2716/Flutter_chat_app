import 'dart:developer';
import 'package:chat_app/models/chatroom_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user_model.dart';
import 'chatroom_page.dart';

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
  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid.toString()}", isEqualTo: true).where("participants.${targetUser.uid.toString()}", isEqualTo: true).get();

    if(snapshot.docs.isNotEmpty){
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingchatroom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingchatroom;

    }else{
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants:{
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
        lastMessageOn: DateTime.now(),
      );
      await FirebaseFirestore.instance.collection("chatrooms").doc(newChatRoom.chatroomid).set(newChatRoom.toMap());
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: "Email Address",
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CupertinoButton(
              color: Colors.blue,
              onPressed: () {
                setState(() {});
              },
              child: const Text("Search")),
          const SizedBox(
            height: 20,
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: searchController.text.trim())
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    if (dataSnapshot.docs.isNotEmpty) {
                      Map<String, dynamic> userMap =
                          dataSnapshot.docs[0].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(userMap);
                      return ListTile(
                        onTap: () async{
                          ChatRoomModel? ChatroomModel = await
                          getChatRoomModel(searchedUser);
                          if(ChatroomModel != null){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomPage(userModel: widget.userModel, targetUser: searchedUser, chatRoomModel: ChatroomModel, firebaseUser: widget.firebaseUser)));
                          }
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchedUser.profilepic!),
                        ),
                        title: Text(searchedUser.fullname!),
                        subtitle: Text(searchedUser.email!),
                        trailing: const Icon(Icons.arrow_right),
                      );
                    } else {
                      return const Text("No results found");
                    }
                  } else if (snapshot.hasError) {
                    return const Text("An error Occured");
                  } else {
                    return const Text("No results Found");
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ]),
      )),
    );
  }
}
