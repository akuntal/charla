import 'package:charla/helper/Utils.dart';
import 'package:charla/helper/theme.dart';
import 'package:charla/services/auth.dart';
import 'package:charla/services/database.dart';
import 'package:charla/views/chatroom.dart';
import 'package:charla/views/forgot_password.dart';
import 'package:charla/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn(this.toggleView);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  final formKey = GlobalKey<FormState>();

  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  bool isLoading = false;

  googleSignUp() async {
    setState(() {
      isLoading = true;
    });

    FirebaseUser user = await authService.signInWithGoogle(context);

    if (user != null) {
      final QuerySnapshot result = await databaseMethods.getUserInfoByUid(user.uid);
      final List<DocumentSnapshot> documents = result.documents;
      setState(() {
        isLoading = false;
      });
      if (documents.length == 1) {
        Utils.saveUserLoggedInSharedPreference(true);
        Utils.saveUserUidSharedPreference(user.uid);
        Utils.saveNameSharedPreference(user.displayName);
        Utils.saveUserEmailSharedPreference(user.email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoom(),
          ),
        );
      } else {
        Fluttertoast.showToast(
            msg: 'User does not exist',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.white,
            timeInSecForIosWeb: 1,
            textColor: Colors.black54);
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        timeInSecForIosWeb: 1,
        textColor: Colors.black54);
  }

  signIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authService
          .signInWithEmailAndPassword(emailController.text, passwordController.text)
          .then((result) async {
        if (result != null) {
          QuerySnapshot userInfoSnapshot =
              await DatabaseMethods().getUserInfo(emailController.text);

          Utils.saveUserLoggedInSharedPreference(true);
          Utils.saveNameSharedPreference(userInfoSnapshot.documents[0].data['name']);
          Utils.saveUserEmailSharedPreference(userInfoSnapshot.documents[0].data['userEmail']);
          Utils.saveUserUidSharedPreference(userInfoSnapshot.documents[0].data['uid']);

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatRoom()));
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }).catchError((e) {
        setState(() {
          isLoading = false;
        });
        showToast(e.message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                Spacer(),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration('email'),
                        controller: emailController,
                        validator: (val) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val)
                              ? null
                              : "Please Enter Correct Email";
                        },
                      ),
                      TextFormField(
                        obscureText: true,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration('password'),
                        validator: (val) {
                          return val.length > 6 ? null : "Enter Password 6+ characters";
                        },
                        controller: passwordController,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => Forgotpassword()));
                      },
                      child: Container(
                        // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Text(
                          'Forgot Password?',
                          style: simpleTextStyle(),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                GestureDetector(
                  onTap: () {
                    signIn();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [const Color(0xff148989), const Color(0xff148989)],
                        )),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'SignIn',
                      style: biggerTextStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                GestureDetector(
                  onTap: () {
                    googleSignUp();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.white),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "Sign In with Google",
                      style: TextStyle(fontSize: 17, color: CustomTheme.textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have account? ",
                      style: simpleTextStyle(),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.toggleView();
                      },
                      child: Text(
                        "Register now",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                )
              ]),
            ),
    );
  }
}
