import 'dart:convert';

import 'package:dasapp/tabs/tutorRegisterationTabs/personalInfo.dart';
import 'package:dasapp/tabs/tutorRegisterationTabs/skills.dart';
import 'package:dasapp/tabs/tutorRegisterationTabs/verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

void main(){
  runApp(TutorRegisterPage());
}

class TutorRegisterPage extends StatefulWidget {

  final userData;
  TutorRegisterPage({@required userData}):this.userData = userData;

  @override
  _TutorRegisterPageState createState() => _TutorRegisterPageState();
}

class _TutorRegisterPageState extends State<TutorRegisterPage> {
  Config appConfiguration = Config();
  bool _loading = false;
  int currentTabIndex = 0;
  var personalInfo;
  var skills;
  var verification;

  void setNextPage(){
    setState(() {
      currentTabIndex +=1;
    });
  }

  Future registerTutor()async{
      try{
        setState(() {
          _loading = true;
        });

        String url = '${appConfiguration.apiBaseUrl}registerUser';
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.files.add(await http.MultipartFile.fromPath('photo',verification['photo']));
        request.files.add(await http.MultipartFile.fromPath('full_photo',verification['full_photo']));
        request.files.add(await http.MultipartFile.fromPath('id_photo',verification['id']));

           personalInfo['location'] = verification['location'];
           personalInfo['lat'] = verification['lat'];
           personalInfo['lng'] = verification['lng'];
           personalInfo['skills'] = skills['skills'].join(',');
           personalInfo['amount'] = skills['amount'];
           personalInfo['institution'] ='';

           //print(personalInfo);

        request.fields.addAll(personalInfo);
        var res = await request.send();
        setState(() {
          _loading = false;
        });

        var response = await res.stream.bytesToString();
        if(response =="error"){
          Fluttertoast.showToast(
              msg: "Oop!s, seems you are already a member of dasApp",
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
          personalInfo['user_id'] = responseData['user_id'];
          personalInfo['photo'] = responseData['photo'];
          storage.setString("userDetails", jsonEncode(personalInfo));
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
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: ()async{
        if(currentTabIndex > 0){
          setState(() {
            currentTabIndex -= 1;
          });
          return false;
        }else{
          Navigator.pop(context);
          return true;
        }

      },
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
          primaryColor: appConfiguration.appColor
        ),
        home:LoadingOverlay(
          isLoading: _loading,
          child: Scaffold(
              appBar: AppBar(
                title: Text("Become a Tutor", style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color:Colors.black),),
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  onPressed: (){
                   if(currentTabIndex > 0){
                     setState(() {
                       currentTabIndex -=1;
                     });
                   }else{
                     Navigator.pop(context);
                   }
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.black,),
                ),
              ),
              body: IndexedStack(
                index: currentTabIndex,
                children: [PersonalInfo(nextPage:(status,data){
                  if(status){
                    setState(() {
                      currentTabIndex +=1;
                      personalInfo = data;
                    });
                  }
                },userData: widget.userData,),Skills(nextPage:(status,data){
                  if(status){
                    setState(() {
                      currentTabIndex +=1;
                      skills = data;
                    });
                  }
                }),Verification(nextPage:(status,data){
                  if(status){
                    setState(() {
                      verification = data;
                    });
                    registerTutor();
                  }
                })],
              )
          ),
        )
      ),
    );
  }

}

Widget tick(bool isChecked, appConfiguration){
  return isChecked?Icon(Icons.check_circle,color:appConfiguration.appColor,):Icon(Icons.radio_button_unchecked, color:appConfiguration.appColor,);
}


Widget spacer() {
  return Container(
    width: 5.0,
  );
}

Widget line(appConfiguration,context) {
  return FractionallySizedBox(
    child: Container(
      color: appConfiguration.appColor,
      height: 5.0,
      width: MediaQuery.of(context).size.width * 0.3
    ),
  );
}
