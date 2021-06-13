import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'dart:async';

void main(){
  runApp(SplashScreen());
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    getUserSession();
  }


  //check if user is logged in then render the home page or login page
  Future getUserSession () async{
    SharedPreferences storage = await SharedPreferences.getInstance();
    var loggedin = storage.getBool("loggedin");
//    storage.setBool("loggedin", true);
//    storage.commit();
    storage.clear();
    if(loggedin == true){
      Timer(Duration(seconds: 2),
              () => Navigator.pushReplacementNamed(context, "/home"));
    }else{
      Timer(Duration(seconds: 2),
              () => Navigator.pushReplacementNamed(context, "/login"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: appBody(),
      ),
    );
  }
}


Widget appBody(){
  Config appConfiguration = new Config();
  return(
      Container(
        color: appConfiguration.appColor,
        child: Align(
          alignment: Alignment.center,
          child: Image.asset(appConfiguration.appSplashLogo,scale: 2.2,),
        ),
      )
  );
}
