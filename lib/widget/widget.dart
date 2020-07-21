import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context, {String title = "Charla"}) {
  return AppBar(
    title: Text(title),
  );
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white54),
      focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)));
}

TextStyle simpleTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 16);
}

TextStyle biggerTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 17);
}
