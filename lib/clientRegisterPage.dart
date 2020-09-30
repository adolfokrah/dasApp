import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:image_picker/image_picker.dart';


void main(){
  runApp(ClientRegisterPage());
}

class ClientRegisterPage extends StatefulWidget {
  final userData;
  ClientRegisterPage({@required userData}):this.userData = userData;
  @override
  _ClientRegisterPageState createState() => _ClientRegisterPageState();
}

class _ClientRegisterPageState extends State<ClientRegisterPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController institutionController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  Config appConfiguration = new Config();
  bool hidePass = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  File _imageFile;
  final ImagePicker _picker = ImagePicker();


  @override
  void initState(){
    if(widget.userData !=null){
      setState(() {
        firstNameController.text = widget.userData["firstName"];
        lastNameController.text = widget.userData["lastName"];
        emailController.text = widget.userData["email"];
      });
    }
  }

  Future register()async{
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState.validate()) {

       if(_imageFile == null){
         Fluttertoast.showToast(
             msg: "Please add your photo",
             toastLength: Toast.LENGTH_LONG,
             gravity: ToastGravity.BOTTOM,
             timeInSecForIosWeb: 1,
             backgroundColor: Colors.red,
             textColor: Colors.white,
             fontSize: 16.0
         );

         return;
       }
       setState(() {
         _loading = true;
       });

       try{
         String url = '${appConfiguration.apiBaseUrl}registerUser';
         var request = http.MultipartRequest('POST', Uri.parse(url));
         request.files.add(await http.MultipartFile.fromPath('photo',_imageFile.path));
         var data = {
           "first_name":firstNameController.text,
           "last_name": lastNameController.text,
           "email": emailController.text,
           "phone_number":phoneNumberController.text,
           "password":passwordController.text,
           "location":"",
           "lat":"0",
           "lng":"0",
           "about":"",
           "amount":"",
           "institution": institutionController.text,
           "sponsor":"",
           "skills":"",
           "qualification":""
         };
         request.fields.addAll(data);
         var res = await request.send();
         setState(() {
           _loading = false;
         });

         var response = await res.stream.bytesToString();
         if(response =="error"){
           Fluttertoast.showToast(
               msg: "Oops!, seems you are already a member of dasApp",
               toastLength: Toast.LENGTH_LONG,
               gravity: ToastGravity.BOTTOM,
               timeInSecForIosWeb: 1,
               backgroundColor: Colors.red,
               textColor: Colors.white,
               fontSize: 16.0
           );
         }else{

           SharedPreferences storage = await SharedPreferences.getInstance();
           var responseData = jsonDecode(response);

           data['user_id'] = responseData['user_id'];
           data['photo'] = responseData['photo'];
           storage.setString("userDetails", jsonEncode(data));
           storage.commit();
           Phoenix.rebirth(context);
         }
       }catch(e){
         print(e);
         setState(() {
           _loading = false;
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

  Future getImage() async {
    try{
      final pickedFile = await _picker.getImage(source: ImageSource.gallery, maxHeight: 300,maxWidth: 300);

      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }catch(e){
      print(e);
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
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.black,),
                ),
              ),
              body:ClientRegisterPageBody()
          ),
        )
    );
  }
  Widget ClientRegisterPageBody(){
    return Form(
      key:_formKey,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Text("Register Now",style: TextStyle(fontSize: 22,fontFamily: "Proxima",fontWeight: FontWeight.bold),),
              ),
              Text("Signup to start hiring teachers",style: TextStyle(fontSize: 15,fontFamily: "Proxima"),),
              Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage:  _imageFile != null ? FileImage(_imageFile) : null,
                        child: InkWell(
                          child:  Container(
                            height: 90,
                            width: 90,
                            child: Icon(Icons.camera_alt),
                          ) ,
                          onTap:(){
                            getImage();
                            //print('gettin image');
                          }
                        ),
                      ),
                    ),
                    TextFormField(
                      controller:firstNameController,
                      validator: (value){
                        if(value.contains(new RegExp(r"[0-9.!#$%&'*+-/=?^_`{|}~]")) || value.isEmpty){
                          return 'Please your a valid name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.account_circle),
                          labelText: "First Name",
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
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: TextFormField(
                        controller:lastNameController,
                        validator: (value){
                          if(value.contains(new RegExp(r"[0-9.!#$%&'*+-/=?^_`{|}~]")) || value.isEmpty){
                            return 'Please your a valid name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle),
                            labelText: "Last Name",
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: TextFormField(
                        controller:emailController,
                        validator: (value){
                          if( !(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) || value.isEmpty){
                            return 'Please your a valid Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
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
                    ),Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        controller:phoneNumberController,
                        validator: (value){

                          if(!(RegExp(r"^[+][0-9]*$").hasMatch(value))){
                            return 'Please start with your country code eg. (+x xxx-xxx-xxxx)';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            labelText: "Phone",
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: TextFormField(
                        controller:passwordController,
                        validator: (value){
                          if((!(value.contains(new RegExp(r"[0-9.!#$%&'*+-/=?^_`{|}~]"))) || value.isEmpty) || value.length < 5){
                            return 'Your password is very week';
                          }
                          return null;
                        },
                        obscureText: hidePass,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: hidePass ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                              onPressed: (){
                                 setState(() {
                                    hidePass = !hidePass;
                                 });
                              },
                            ),
                            prefixIcon: Icon(Icons.lock),
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Text("Are you an institution?",style: TextStyle(fontSize: 13,fontFamily: "proxima"),),
                          IconButton(
                            onPressed: (){
                              showInfoBox();
                            },
                            padding: EdgeInsets.all(0),
                            icon: Icon(Icons.help,size:20,color: appConfiguration.appColor),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: TextFormField(
                        controller:institutionController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.school),
                            labelText: "Institution Name (optional)",
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
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: FlatButton(
                        padding: EdgeInsets.all(15),
                        onPressed: (){
                            register();
                        },
                        color: appConfiguration.appColor,
                        child: Text("Register as a client",style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  )
                  ],
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showInfoBox() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("DasApp is also a platform for recruiting teachers to institutions, so we might want to know if you are registering on behalf of one. This step is option",style: TextStyle(fontFamily: "Proxima"),)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Okay",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color: appConfiguration.appColor),),
              onPressed: (){
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
