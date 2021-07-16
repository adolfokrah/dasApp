import 'dart:convert';

import 'package:dasapp/clientRegisterPage.dart';
import 'package:dasapp/tutorRegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'forgottenPassword.dart';

void main(){
  runApp(Login());
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Config appConfiguration = new Config();
  GoogleSignIn _googleSignIn = GoogleSignIn();
  final facebookLogin = FacebookLogin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool hidePass = true;
  var userDetails;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();






  Future Login(social)async{
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState.validate() || social) {
      setState(() {
        isLoading = true;
      });

      try{
        String url = '${appConfiguration.apiBaseUrl}loginUser';
        var data = {
          "email": emailController.text,
          "password":passwordController.text,
          "validatePass": social  ? "no" : "yes"

        };
        var response = await http.post(Uri.parse(url),body:data);
        setState(() {
          isLoading = false;
        });
        //print(data);
        if(response.body =="error"){
          if(social){
            _showMyDialog();
           return;
          }

          Fluttertoast.showToast(
              msg: "Oop!s, you provided the wrong credentials",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );

        }else{

          SharedPreferences storage = await SharedPreferences.getInstance();

          storage.setString("userDetails", response.body);
          storage.commit();
          Phoenix.rebirth(context);
        }
      }catch(e){
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Connection failed, please try again later",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }

    }

  }

  Future<void> googleSignin() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _googleSignIn.signIn();
      setState(() {
        isLoading = false;
      });
      var name = _googleSignIn.currentUser.displayName.split(' ');
      var data = {
        "firstName": name[0],
        "lastName": name[1],
        "email": _googleSignIn.currentUser.email
      };
      setState(() {
        emailController.text = _googleSignIn.currentUser.email;
        userDetails = data;
      });
      Login(true);
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print(error);
    }
  }

  Future<void> facebookSignin() async{
    try{
      setState(() {
        isLoading = true;
      });
      final result = await facebookLogin.logIn(['email']);
      setState(() {
        isLoading = false;
      });
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final token = result.accessToken.token;
          final graphResponse = await http.get(Uri.parse(
              'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token='+token));
              final profile = jsonDecode(graphResponse.body);

              var data = {
                "firstName": profile['first_name'],
                "lastName": profile['last_name'],
                "email": profile['email']
              };
              setState(() {
                emailController.text = profile['email'];
                userDetails = data;
              });
              Login(true);
          break;
        case FacebookLoginStatus.cancelledByUser:

          break;
        case FacebookLoginStatus.error:

          break;
      }
    }catch(e){
      setState(() {
        isLoading = false;
      });
        print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0
          ),
          body:loginContainer()
      ),
    );
  }


  Widget loginContainer(){
    return Form(
      key:_formKey,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text("Login Now",style: TextStyle(fontSize: 22,fontFamily: "Proxima",fontWeight: FontWeight.bold),),
                ),
                Text("Please login to continue using our app",style: TextStyle(fontSize: 15,fontFamily: "Proxima"),),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: emailController,
                        validator: (value){
                          if( !(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) || value.isEmpty){
                            return 'Please your a valid Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Proxima',
                            ),
                            enabledBorder:OutlineInputBorder(
                                borderSide:  BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            focusedBorder:OutlineInputBorder(
                                borderSide:  BorderSide(color: appConfiguration.appColor),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:  BorderSide(color: Colors.black12),
                            )
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child:TextFormField(
                          controller: passwordController,
                          obscureText: hidePass,
                            validator: (value){
                              if(value.isEmpty){
                                return 'Your password is needed';
                              }
                              return null;
                            },
                          decoration: InputDecoration(
                             suffixIcon: IconButton(
                               onPressed: (){
                                 setState(() {
                                   hidePass = !hidePass;
                                 });
                               },
                               icon: hidePass ? Icon(Icons.visibility) : Icon(Icons.visibility_off) ,
                             ),
                              labelText: "Password",
                              labelStyle: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Proxima',
                              ),
                              enabledBorder:OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              focusedBorder:OutlineInputBorder(
                                  borderSide:  BorderSide(color: appConfiguration.appColor),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:  BorderSide(color: Colors.black12),
                              )
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) => ForgottenPassword()));
                        },
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                            child: Text("Forgot password?",style: TextStyle(color: appConfiguration.appColor,fontFamily: "Proxima",fontSize: 15,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          padding: EdgeInsets.all(16),
                          onPressed: (){Login(false);},
                          color:appConfiguration.appColor,
                          child: Text("Login to my account",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Proxima"),),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Text("Or login instantly with",style: TextStyle(color: Colors.black54,fontFamily: "Proxima"),),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: 150,
                            child: OutlineButton(
                              padding: EdgeInsets.all(12),
                              onPressed: (){
                                facebookSignin();
                              },
                              child: Image.asset("assets/images/facebook.png",height: 20,width: 20,),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: OutlineButton(
                              padding: EdgeInsets.all(12),
                              onPressed: (){
                                googleSignin();
                              },
                              child: Image.asset("assets/images/google.png",height: 20,width: 20,),
                            ),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: (){
                          setState(() {
                            userDetails = null;
                          });
                          _showMyDialog();
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Don't have an account?",style: TextStyle(fontFamily: "Proxima",color: Colors.black54),),
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text("Register",style: TextStyle(fontFamily: "Proxima",color: appConfiguration.appColor,fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('I want to:',style: TextStyle(fontFamily: "Proxima"),textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                OutlineButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => ClientRegisterPage(userData: userDetails)));
                  },
                  child: Text("Hire a teacher"),
                ),
                OutlineButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => TutorRegisterPage(userData: userDetails)));
                  },
                  child: Text("Work as a teacher"),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
