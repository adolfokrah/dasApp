import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

void main(){
  runApp(ChangePassword());
}

class ChangePassword extends StatefulWidget {
  final userId;
  ChangePassword ({@required userId}):this.userId = userId;
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  Config appConfiguration = Config();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  var hidePass = true;

  updatePassword()async{
    try{
        if(_formKey.currentState.validate()){
          setState(() {
            _loading = true;
          });

          String url = '${appConfiguration.apiBaseUrl}updatePassword';
          var data = {
            'user_id' : widget.userId,
            'newPass' : newPasswordController.text,
            'oldPass':  oldPasswordController.text
          };
          var response = await http.post(Uri.parse(url),body:data);
          setState(() {
            _loading = false;
          });

          if(response.body == 'error'){
            Fluttertoast.showToast(
                msg: "Oops!, your old password is incorrect password",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }else{
            Fluttertoast.showToast(
                msg: "Password updated",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.pop(context);
          }
        }
    }catch(e){
      print(e);
      Fluttertoast.showToast(
        msg: "Sorry! an error occurred please try agian later",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: appConfiguration.appColor
        ),
        home:LoadingOverlay(
          isLoading: _loading,
          child: Scaffold(
              appBar: AppBar(
                title: Text("Change your password", style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color:Colors.white),),
                backgroundColor: appConfiguration.appColor,
                elevation: 0,
                leading: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close,color: Colors.white,),
                ),
              ),
              body: ChangePasswordBody()
          ),
        )
    );
  }

  Widget ChangePasswordBody(){
    return Form(
      key:_formKey,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: oldPasswordController,
                        obscureText: hidePass,
                        validator: (value){
                          if(value.isEmpty){
                            return 'Your old password is needed';
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
                            labelText: "Your Old Password",
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
                          controller: newPasswordController,
                          obscureText: hidePass,
                          validator: (value){
                            if((!(value.contains(new RegExp(r"[0-9.!#$%&'*+-/=?^_`{|}~]"))) || value.isEmpty) || value.length < 5){
                              return 'Your password is very week';
                            }
                            return null;
                          },
                          decoration: InputDecoration(

                              labelText: "Your New Password",
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
                        margin: EdgeInsets.only(top: 10),
                        child: FlatButton(
                          padding: EdgeInsets.all(16),
                          onPressed: (){
                            updatePassword();
                          },
                          color:appConfiguration.appColor,
                          child: Text("Change password",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Proxima"),),
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
