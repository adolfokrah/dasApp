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


void main(){
  runApp(ForgottenPassword());
}

class ForgottenPassword extends StatefulWidget {
  @override
  _ForgottenPasswordState createState() => _ForgottenPasswordState();
}

class _ForgottenPasswordState extends State<ForgottenPassword> {
  Config appConfiguration = new Config();

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






  Future ForgottenPassword()async{
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      try{
        String url = '${appConfiguration.apiBaseUrl}sendNewPassword';
        var data = {
          "email": emailController.text,

        };
        var response = await http.post(Uri.parse(url),body:data);
        setState(() {
          isLoading = false;
        });
        //print(data);
        if(response.body =="error"){

          Fluttertoast.showToast(
              msg: "Oop!s, you provided the wrong email",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );

        }else{
          Fluttertoast.showToast(
              msg: "A new password has been sent to your mail and via sms",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
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



  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
          appBar: AppBar(
             leading: IconButton(
               onPressed: (){
                 Navigator.pop(context);
               },
               icon: Icon(Icons.arrow_back,color:Colors.black),
             ),
              backgroundColor: Colors.white,
              elevation: 0
          ),
          body:ForgottenPasswordContainer()
      ),
    );
  }


  Widget ForgottenPasswordContainer(){
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
                  child: Text("Forgotten Password",style: TextStyle(fontSize: 22,fontFamily: "Proxima",fontWeight: FontWeight.bold),),
                ),
                Text("Please enter your email to reset your password",style: TextStyle(fontSize: 15,fontFamily: "Proxima"),),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: TextFormField(
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
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          padding: EdgeInsets.all(16),
                          onPressed: (){ForgottenPassword();},
                          color:appConfiguration.appColor,
                          child: Text("Submit",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Proxima"),),
                        ),
                      ),
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

}
