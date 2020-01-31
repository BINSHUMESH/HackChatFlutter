import 'package:flutter/material.dart';
import 'package:flash_chat/buttonDesign.dart';
import 'package:flash_chat/constants.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegistrationScreen extends StatefulWidget {
  static String id='RegistrationScreen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String channelId;
  bool spinner=false;
  final _firestore=Firestore.instance;
  Future<bool> isCreated()async{
     var check=await _firestore.collection(channelId).getDocuments();
     if(check.documents.isEmpty){
       await _firestore.collection(channelId).add({
         'text':'Channel Created'
       });
       return true;
     }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: spinner,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                obscureText: true,
                style: TextStyle(
                  color: Colors.black
                ),
                onChanged: (value) {
                  setState(() {
                    channelId=value;
                  });
                },
                decoration: kInputDecoration.copyWith(
                  hintText: 'Enter Channel Id'
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              ButtonDesign(
                color: Colors.blueAccent,
                text: 'Create Channel',
                callback: ()async{
                  setState(() {
                    spinner=true;
                  });
                  if(await isCreated()) {
                    Navigator.pushNamed(context, ChatScreen(channelId: channelId,).id);
                  }
                  else {
                    Fluttertoast.showToast(
                        msg: "Choose Different Channel Name",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIos: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
                  setState(() {
                    spinner=false;
                });
              },),
            ],
          ),
        ),
      ),
    );
  }
}
