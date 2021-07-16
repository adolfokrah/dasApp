import 'dart:convert';
import 'dart:io';

import 'package:dasapp/mySkills.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'functions.dart';
import 'locationSearch.dart';
import 'login.dart';

void main(){
  runApp(ProfilePage());
}

class ProfilePage extends StatefulWidget {
  final teacher;

  ProfilePage({@required teacher}):this.teacher = teacher;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Config appConfiguration = new Config();
  Functions functions = new Functions();
  bool top = false;
  ScrollController _scrollController = new ScrollController();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController institutionController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  var _teacherDetails;
  var _loading = true;
  var updating = false;
  var userId;
  var userType = 'client';
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File _imageFile;
  var address = "";
  var lat = "";
  var lng = "";
  var updated = false;
  var skills = "";
  @override
  void initState(){
    if (!mounted) return;

    super.initState();


    firstNameController.text = widget.teacher['first_name'];
    lastNameController.text = widget.teacher['last_name'];
    emailController.text = widget.teacher['email'];
    phoneNumberController.text = widget.teacher['phone'];
    qualificationController.text = widget.teacher['qualification'];
    aboutController.text = widget.teacher['about'];
    institutionController.text = widget.teacher['institution_name'];
    amountController.text = widget.teacher['amount'];

    setState(() {
      _teacherDetails = widget.teacher;
      lat = widget.teacher['lat'];
      lng = widget.teacher['lng'];
      skills = widget.teacher['skills'];
      address = widget.teacher['location'];
    });

    getUserDetails();
    fetchTutorDetails(widget.teacher['user_id']);

    _scrollController.addListener(() {
      if(_scrollController.offset > 250){
        setState(() {
          top = true;
        });
      }else{
        setState(() {
          top = false;
        });
      }
    });

  }

  getUserDetails()async{
    SharedPreferences storage = await SharedPreferences.getInstance();
    String userDetails = storage.getString('userDetails');
    String user_id = "0";
    if(userDetails != null){
      var userDetailsArray = jsonDecode(userDetails);
      user_id = userDetailsArray['user_id'];
      if (!mounted) return;
      setState(() {
        userId = user_id;
      });
      if(userDetailsArray['skills']!=""){
        setState(() {
          userType = "teacher";
        });
      }
    }
  }

  void fetchTutorDetails(_id) async{
    try{
      var url = '${appConfiguration.apiBaseUrl}fetchUserProfile';
      final request = await http.post(Uri.parse(url),body:{'userId':_id});
      if(request.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _loading = false;
        });
        var data = jsonDecode(request.body);
        setState(() {
          _teacherDetails = data['profile'];
        });
      }
    }catch(e){
      print(e);
    }
  }

   updateProfile()async{
      if(_formKey.currentState.validate()){
        try{
          setState(() {
            updating = true;
          });

          var data = {
            "user_id": userId.toString(),
            "about": aboutController.text,
            "institution": institutionController.text,
            "qualification": qualificationController.text,
            "skills": skills,
            "lat": lat,
            "lng": lng,
            "address": address,
            "amount": amountController.text,
            "first_name": firstNameController.text,
            "last_name": lastNameController.text,
            "email": emailController.text,
            "phone":phoneNumberController.text
          };
          String url = '${appConfiguration.apiBaseUrl}updateProfile';
          var response;

          if(_imageFile != null){
            var request = http.MultipartRequest('POST', Uri.parse(url));
            request.files.add(await http.MultipartFile.fromPath('photo',_imageFile.path));
            request.fields.addAll(data);
            var res = await request.send();



            response = await res.stream.bytesToString();
          }else{
            var req = await http.post(Uri.parse(url),body: data);
            response = req.body;
          }
          if (!mounted) return;
          setState(() {
            updating = false;
          });

          if(response =="error"){
            Fluttertoast.showToast(
                msg: "Oops! it seems your new email is already available",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }else{
            Fluttertoast.showToast(
                msg: "Profile updated",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            if (!mounted) return;
            setState(() {
              updated = true;
            });


            SharedPreferences storage = await SharedPreferences.getInstance();
            storage.setString("userDetails", response);
            storage.commit();

          }
        }catch(e){
          if (!mounted) return;
          setState(() {
            _loading  = false;
          });
          Fluttertoast.showToast(
              msg: "Oops! connection failed, please try again later",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
          print(e);
        }
      }
    }





  Future getImage() async {
    try{
      var  pickedFile = await _picker.getImage(source: ImageSource.gallery, maxHeight: 300,maxWidth: 300);

      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }catch(e){
      print(e);
    }
  }

  Future getUserLocation()async{
    final results = await Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => LocationSearch()));
    if(results != null){
      var arguments = jsonDecode(results);
      setState(() {
        lat = arguments['lat'];
        lng = arguments['lng'];
        address = arguments['address'];
      });
    }
  }
  Future getSkills()async{
    final results = await Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => MySkills(skills: skills)));
    if(results != null){
      setState(() {
        skills = results;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.pop(context,updated);
        return true;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: appConfiguration.appColor
        ),
        home: LoadingOverlay(
          isLoading: updating,
          child: Scaffold(
            body:CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: 300,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,color: top ? Colors.white : Colors.black,),
                    onPressed: (){
                      Navigator.pop(context,updated);
                    },
                  ),
                actions: userType == 'client' ? null : [
                  PopupMenuButton<int>(
                    icon: Icon(Icons.more_vert,color: top ? Colors.white : Colors.black,),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Text("Share profile"),
                      ),
                    ],
                    onSelected: (value){
                      if(value == 1){
                        Share.share('https://dasapp.page.link/?link=https://dasapp.biztrustgh.com/teacher?id%3D${_teacherDetails['user_id']}%26name%3D${_teacherDetails['first_name'].replaceAll(' ','%20')}-${_teacherDetails['last_name'].replaceAll(' ','%20')}&apn=com.dasapp&efr=1');
                      }
                    },
                  )
                ],
                  title: top ? Text(_teacherDetails['first_name']+" "+_teacherDetails['last_name'].substring(0,1)+'.',style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,),) : null,
                  flexibleSpace:  FlexibleSpaceBar(
                    background: Container(
                      color: Color(0xffF7F7F7),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 70, 0, 0),
                        child: Column(
                          children: <Widget>[
                            InkWell(
                              onTap: (){
                                getImage();
                              },
                              child: Hero(
                                tag: 'user',
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundImage:  _imageFile != null ? FileImage(_imageFile) : NetworkImage('${appConfiguration.usersImageFolder}${_teacherDetails['photo']}'),
                                ),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(_teacherDetails['first_name']+' '+_teacherDetails['last_name'],style: TextStyle(fontSize: 18,fontFamily: "Proxima",fontWeight: FontWeight.bold),),
                                    Container(
                                      child: _teacherDetails['verified'] == 'yes' ? Icon(Icons.verified_user,color: Colors.green,) : null,
                                    )
                                  ],
                                )

                            ),
                            Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: _loading ? Container(
                                  height: 10,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                ):Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.fromLTRB(
                                            0, 0, 5, 0),
                                        child: Icon(Icons.star,
                                          color: Color(0xfff7b709),
                                          size: 18,)),
                                    Text(
                                      ((_teacherDetails['reviews'] + 1 / 100) *
                                          5).toStringAsFixed(2).toString()+'/5',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,fontFamily:"Proxima"),),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          10, 0, 0, 0),
                                      child: Text(
                                        _teacherDetails['reviews'].toString() +
                                            " reviews",style: TextStyle(fontFamily: "Proxima"),),
                                    )
                                  ],
                                )
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children : userType == 'client'  ? [] : <Widget>[
                                    Text('₵ '+_teacherDetails['amount']+'/',style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text(_teacherDetails['Upayment_plan'],style: TextStyle(fontSize: 11,color:Colors.black54),)
                                  ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  // Use a delegate to build items as they're scrolled on screen.
                  delegate: SliverChildListDelegate(
                      userType == 'client'? [clientForm()] : [tutorForm()]
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget clientForm(){
    return Padding(
        padding: EdgeInsets.fromLTRB(20,20,20,0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
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
                  controller: lastNameController,
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
                  controller:  emailController,
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
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
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
                      updateProfile();
                    },
                    color: appConfiguration.appColor,
                    child: Text("Continue",style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget tutorForm(){
    return Padding(
      padding: EdgeInsets.fromLTRB(20,20,20,0),
      child: Form(
        key: _formKey,
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
                readOnly: true,
                controller:TextEditingController(text: skills),
                onTap: (){
                  getSkills();
                },
//                validator: (value){
//                  if( !(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) && value.isNotEmpty){
//                    return 'Your referral\'s  Email is invalid';
//                  }
//                  return null;
//                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.star),
                    labelText: "My Skills",
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
                readOnly: true,
                controller:TextEditingController(text: address),
                onTap: (){
                  getUserLocation();
                },
                validator: (value){
                  if(value.isEmpty){
                    return 'Your location is needed';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.location_on),
                    labelText: "Your location",
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
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  validator: (value){
                    try{
                      if(double.parse(value) < 150){
                        return "You charge should be greater than 149";
                      }
                      return null;
                    }catch(e){
                      return 'Please enter a valid figure';
                    }
                  },
                decoration: InputDecoration(
                    prefixText: "GHS ",
                    labelText: "How munch do you charge per month?",
                    suffixText: "Monthly",
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
                    updateProfile();
                  },
                  color: appConfiguration.appColor,
                  child: Text("Continue",style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
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

