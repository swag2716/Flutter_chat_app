import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/chatroom_model.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel userModel;
  final UserModel targetUser;
  final ChatRoomModel chatRoomModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.userModel,
      required this.targetUser,
      required this.chatRoomModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();
  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());
      widget.chatRoomModel.lastMessage = msg;
      widget.chatRoomModel.lastMessageOn = DateTime.now();

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .set(widget.chatRoomModel.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(widget.targetUser.fullname.toString()),
          ],
        ),
      ),
      body: SafeArea(
          child: Container(
        child: Column(children: [
          Expanded(
            child: Container(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatRoomModel.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;
                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            return Row(
                              mainAxisAlignment: (currentMessage.sender ==
                                      widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (currentMessage.sender ==
                                              widget.userModel.uid)
                                          ? Colors.grey
                                          : Colors.blue,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      currentMessage.text.toString(),
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text("An error occured"),
                        );
                      } else {
                        return const Center(
                          child: Text("Say Hi to your new friend"),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
          ),
          Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                    controller: messageController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Message",
                    ),
                  )),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                  )
                ],
              ),
            ),
          )
        ]),
      )),
    );
  }
}
