class ChatRoomModel{
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? lastMessageOn;

  ChatRoomModel({this.chatroomid, this.participants, this.lastMessage, this.lastMessageOn});

  ChatRoomModel.fromMap(Map<String, dynamic>map){
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
    lastMessageOn = map["lastMessageOn"];
  }

  Map<String, dynamic> toMap(){
    return{
      "chatroomid": chatroomid,
      "participants": participants,
      "lastMessage": lastMessage,
      "lastMessageOn": lastMessageOn,
    };
  }
}