import 'package:chat_app/models/chatroom_model.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/pages/chatroom_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chat App"),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: SafeArea(
          child: Container(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${widget.userModel.uid.toString()}",
                    isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;
                  return ListView.builder(
                      itemCount: chatRoomSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                            chatRoomSnapshot.docs[index].data()
                                as Map<String, dynamic>);
                        Map<String, dynamic>? participants =
                            chatRoomModel.participants;

                        List<String> participantKeys =
                            participants!.keys.toList();
                        participantKeys.remove(widget.userModel.uid);

                        return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participantKeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  UserModel targetUser =
                                      userData.data as UserModel;

                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatRoomPage(
                                                      userModel:
                                                          widget.userModel,
                                                      targetUser: targetUser,
                                                      chatRoomModel:
                                                          chatRoomModel,
                                                      firebaseUser: widget
                                                          .firebaseUser)));
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(targetUser.profilepic!),
                                    ),
                                    title: Text(targetUser.fullname!),
                                    subtitle: (chatRoomModel
                                            .lastMessage!.isNotEmpty)
                                        ? Text(chatRoomModel.lastMessage!)
                                        : const Text(
                                            "Say Hi to your new friend!",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            });
                      });
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return const Center(child: Text("No Chats"));
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      )),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchPage(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser)));
          },
          child: const Icon(
            Icons.search,
          )),
    );
  }
}
