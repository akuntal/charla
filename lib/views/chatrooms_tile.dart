import 'package:charla/helper/theme.dart';
import 'package:charla/services/database.dart';
import 'package:charla/views/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoomsTile extends StatefulWidget {
  final String uid;
  final String chatRoomId;

  ChatRoomsTile({this.uid, @required this.chatRoomId});

  @override
  _ChatRoomsTileState createState() => _ChatRoomsTileState();
}

class _ChatRoomsTileState extends State<ChatRoomsTile> {
  String name = '';

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    QuerySnapshot userInfo = await DatabaseMethods().getUserInfoByUid(widget.uid);
    setState(() {
      name = userInfo.documents[0].data['displayName'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Chat(chatRoomId: widget.chatRoomId);
        }));
      },
      child: Container(
        color: Colors.black26,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: CustomTheme.colorAccent, borderRadius: BorderRadius.circular(30)),
              child: Text(name.length > 0 ? name.substring(0, 1) : name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300)),
            ),
            SizedBox(
              width: 12,
            ),
            Text(name,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300))
          ],
        ),
      ),
    );
  }
}
