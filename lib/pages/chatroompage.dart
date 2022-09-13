import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          child: Column(children: [
            Expanded(child: Container(),
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
                    
                  const Flexible(child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Message",
                    ),
                  )),
                 IconButton(onPressed: (){},
                 icon: const Icon(Icons.send),color: Colors.blue,)
                ],
                ),
              ),
            )
          ]),
        )),
    );
  }
}
