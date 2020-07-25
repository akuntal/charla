import 'package:charla/helper/Utils.dart';
import 'package:charla/helper/theme.dart';
import 'package:charla/services/auth.dart';
import 'package:charla/services/database.dart';
import 'package:charla/views/chatroom.dart';
import 'package:charla/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Signup extends StatefulWidget {
  final Function toggleView;

  Signup(this.toggleView);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController usernameEditingController = new TextEditingController();

  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  googleSignUp() async {
    Map<String, dynamic> userMap = {};

    setState(() {
      isLoading = true;
    });
    FirebaseUser user = await authService.signInWithGoogle(context);
    setState(() {
      isLoading = false;
    });
    if (user != null) {
      final QuerySnapshot result = await databaseMethods.getUserInfoByUid(user.uid);

      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        userMap['name'] = user.displayName;
        userMap['displayName'] = user.displayName;
        userMap['email'] = user.email;
        userMap['uid'] = user.uid;
        userMap['photoUrl'] = user.photoUrl;
        userMap['createdAt'] = Timestamp.now();
        databaseMethods.addUserInfo(userMap);

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
            msg: 'User Already Exist!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.white,
            timeInSecForIosWeb: 1,
            textColor: Colors.black54);
      }
    }
  }

  signUp() async {
    if (formKey.currentState.validate()) {
      Map<String, dynamic> userMap = {
        'name': usernameEditingController.text,
        'email': emailEditingController.text,
        'displayName': usernameEditingController.text,
        'createdAt': Timestamp.now()
      };
      setState(() {
        isLoading = true;
      });

      await authService
          .signUpWithEmailAndPassword(emailEditingController.text, passwordEditingController.text)
          .then((result) {
        if (result != null) {
          userMap['uid'] = result.uid;
          databaseMethods.addUserInfo(userMap);

          Utils.saveUserLoggedInSharedPreference(true);
          Utils.saveUserUidSharedPreference(result.uid);
          Utils.saveNameSharedPreference(usernameEditingController.text);
          Utils.saveUserEmailSharedPreference(emailEditingController.text);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoom(),
            ),
          );
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }).catchError((e) {
        print(e.toString());
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Spacer(),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: usernameEditingController,
                          style: simpleTextStyle(),
                          validator: (val) {
                            return val.isEmpty || val.length < 3
                                ? "Enter Name 3+ characters"
                                : null;
                          },
                          decoration: textFieldInputDecoration('name'),
                        ),
                        TextFormField(
                          controller: emailEditingController,
                          style: simpleTextStyle(),
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Enter correct email";
                          },
                          decoration: textFieldInputDecoration("email"),
                        ),
                        TextFormField(
                          obscureText: true,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration("password"),
                          controller: passwordEditingController,
                          validator: (val) {
                            return val.length < 6 ? "Enter Password 6+ characters" : null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      signUp();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [const Color(0xff007EF4), const Color(0xff2A75BC)],
                          )),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "Sign Up",
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
                      // sign up
                      googleSignUp();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30), color: Colors.white),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "Sign Up with Google",
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
                        "Already have an account? ",
                        style: simpleTextStyle(),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Text(
                          "SignIn now",
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
                ],
              ),
            ),
    );
  }
}
