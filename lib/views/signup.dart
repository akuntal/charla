import 'package:charla/helper/HelperFunctions.dart';
import 'package:charla/helper/theme.dart';
import 'package:charla/services/auth.dart';
import 'package:charla/services/database.dart';
import 'package:charla/views/chatroom.dart';
import 'package:charla/widget/widget.dart';
import 'package:flutter/material.dart';

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

  signUp() async {
    if (formKey.currentState.validate()) {
      Map<String, String> userMap = {
        'name': usernameEditingController.text,
        'userEmail': emailEditingController.text,
        'displayName': usernameEditingController.text
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

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserUidSharedPreference(result.uid);
          HelperFunctions.saveNameSharedPreference(usernameEditingController.text);
          HelperFunctions.saveUserEmailSharedPreference(emailEditingController.text);

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
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.white),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "Sign Up with Google",
                      style: TextStyle(fontSize: 17, color: CustomTheme.textColor),
                      textAlign: TextAlign.center,
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
