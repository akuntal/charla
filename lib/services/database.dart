import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData) async {
    Firestore.instance.collection('users').add(userData).catchError((e) => print(e.toString()));
  }

  getUserInfo(String email) async {
    return Firestore.instance
        .collection('users')
        .where('userEmail', isEqualTo: email)
        .getDocuments()
        .catchError((e) => print(e.toString()));
  }

  getUserInfoByUid(String uid) async {
    return Firestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .getDocuments()
        .catchError((e) => print(e.toString()));
  }

  searchByName(String displayName) {
    return Firestore.instance
        .collection('users')
        // .where('displayName', isEqualTo: displayName)
        .getDocuments()
        .catchError((e) => print(e.toString()));
  }

  Future<void> addChatRoom(chatRoom, chatRoomId) async {
    Firestore.instance
        .collection('chatRoom')
        .document(chatRoomId)
        .setData(chatRoom)
        .catchError((e) => print(e.toString()));
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection('chatRoom')
        .document(chatRoomId)
        .collection('chats')
        .orderBy('time')
        .snapshots();
  }

  Future<void> addMessage(String chartRoomId, chatMessage) async {
    Firestore.instance
        .collection('chatRoom')
        .document(chartRoomId)
        .collection('chats')
        .add(chatMessage)
        .catchError((e) => print(e.toString()));
  }

  getUserChats(String uid) async {
    return Firestore.instance.collection('chatRoom').where('users', arrayContains: uid).snapshots();
  }
}
