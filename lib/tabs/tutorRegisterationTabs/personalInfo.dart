import 'package:dasapp/tutorRegisterPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import '../../config.dart';

void main(){
  runApp(PersonalInfo());
}

class PersonalInfo extends StatefulWidget {
  final Function nextPage;
  final userData;
  PersonalInfo({@required nextPage, @required userData}) : this.nextPage = nextPage, this.userData = userData;
  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  var counter = 0;
  bool hidePass = true;


  final _formKey = GlobalKey<FormState>();
  Config appConfiguration = Config();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController sponsorController = TextEditingController();

  void initState(){
    if(widget.userData !=null){
      if(!mounted) return;
      setState(() {
        firstNameController.text = widget.userData["firstName"];
        lastNameController.text = widget.userData["lastName"];
        emailController.text = widget.userData["email"];
      });
    }
    initDynamicLinks();
  }

  void initDynamicLinks() async {
    await Firebase.initializeApp();
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;
          if (deepLink != null) {
            openPageFromUrl(deepLink);
          }
        },


        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);
        }
    );

    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      openPageFromUrl(deepLink);
    }
  }

  openPageFromUrl(deepLink){
    var link =  Uri.dataFromString(deepLink.toString());
    if(deepLink.path == '/register'){
      //print(deepLink);
      var sponsor = link.queryParametersAll['sponsor'][0];
      //print(sponsor);
      sponsorController.text  = sponsor;
    }
  }

  void validate(){
    if(_formKey.currentState.validate()){
      var data = {
        "first_name":firstNameController.text,
        "last_name": lastNameController.text,
        "email": emailController.text,
        "phone_number":phoneNumberController.text,
        "password":passwordController.text,
        "qualification":qualificationController.text,
        "about":aboutController.text,
        "sponsor":sponsorController.text,
      };
        widget.nextPage(true,data);
    }
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      child: Form(
        key: _formKey,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children :[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      tick(true, appConfiguration),
                      spacer(),
                      line(appConfiguration,context),
                      tick(false, appConfiguration),
                      spacer(),
                      line(appConfiguration,context),
                      tick(false, appConfiguration)
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          TextFormField(
                            controller:firstNameController,
                            validator: (value){
                              if(value.contains(new RegExp(r"[0-9.!#$%&'*+-/=?^_`{|}~]")) || value.isEmpty){
                                return 'Please your enter a valid name';
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
                            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                            child: TextFormField(
                              controller:qualificationController,
                              validator: (value){
                                if(value.isEmpty){
                                  return 'Your qualification is needed';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.school),
                                  labelText: "Qualification",
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
                              controller:aboutController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              textInputAction: TextInputAction.newline,
                              validator: (value){
                                if(value.isEmpty){
                                  return 'Please tell us about your self';
                                }
                                if(value.length < 100){
                                  return 'Your about is not enough, max of 100 characters';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.info),
                                  labelText: "Tell us about your self",
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
                              controller:sponsorController,
                              validator: (value){
                                if( !(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) && value.isNotEmpty){
                                  return 'Your referral\'s  Email is invalid';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  labelText: "Who referred you here? (optional)",
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
                                  validate();
                                },
                                color: appConfiguration.appColor,
                                child: Text("Continue",style: TextStyle(color: Colors.white),),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]
          ),

        ),
      ),
    );
  }
}
