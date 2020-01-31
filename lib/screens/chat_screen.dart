import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String id='ChatScreen';
  final String channelId;
  ChatScreen({Key key,@required this.channelId}):super(key:key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore=Firestore.instance;
  String messageText;
  final _auth=FirebaseAuth.instance;
  FirebaseUser user;
  void getUser()async{
    try {
      user=await _auth.currentUser();
      if(user!=null)
        print(user.email);
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getUser();
    print(widget.channelId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️'+widget.channelId),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').orderBy('timestamp').snapshots(),
                builder: (context,snapshot){
                  if(!snapshot.hasData){
                    return CircularProgressIndicator(
                      backgroundColor: Colors.blueAccent,
                    );
                  }
                  List<MessageBubble> messageText=[];
                  var messages=snapshot.data.documents.reversed;
                  for(var message in messages){
                    String text=message.data['text'];
                    String sender=message.data['sender'];
                    final messageWidget=MessageBubble(text: text,sender: sender,isMe: user.email==sender,);
                    messageText.add(messageWidget);
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      children: messageText,
                    ),
                  );
                }
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                      style: TextStyle(
                        color: Colors.black
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _firestore.collection('messages').add({
                        'text':messageText,
                        'timestamp':DateTime.now()
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageBubble extends StatelessWidget {
  MessageBubble({this.text,this.sender,this.isMe});
  final String text,sender;
  final bool isMe;
  Color setColorBubble(){
    if(isMe)
      return Colors.white;
    else
      return Colors.lightBlue;
  }
  Color setColorBubbleText(){
    if(isMe)
      return Colors.black54;
    else
      return Colors.white;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.start:CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.w300
            ),
          ),
          Material(
            elevation: 10,
            borderRadius: BorderRadius.only(
              topLeft:isMe?Radius.circular(0):Radius.circular(30),
              topRight: isMe?Radius.circular(30):Radius.circular(0),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)
            ),
            color: setColorBubble(),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: setColorBubbleText()
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
