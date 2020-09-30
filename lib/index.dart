
import 'package:dasapp/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'login.dart';
import 'tabs/postJob.dart';
import 'config.dart';
import 'package:dasapp/locationSearch.dart';
import 'searchPage.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'functions.dart';

void main(){
  //call the initial route (splashScreen)
  runApp(Phoenix(
    child: Index(),
  ));
}

class Index extends StatefulWidget {
  @override
  _Index createState() => _Index();
}

class _Index extends State<Index> {
  Config appConfiguration = Config();
  Functions functions = new Functions();
  var login = false;
  var firstTime = true;
  var init = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAuth();
  }

  Future checkAuth()async{
    SharedPreferences storage = await SharedPreferences.getInstance();
    String userDetails = storage.getString('userDetails');
    String userfirstTime = storage.getString('userFirstTime');
    if(userfirstTime != null){
      setState(() {
        firstTime = false;
      });
    }

    setState(() {
      init = false;
    });

    if(userDetails != null){
       setState(() {
         login = true;
       });
      return;
    }
  }

  Future userFirstTime()async{
    SharedPreferences storage = await SharedPreferences.getInstance();
    storage.setString("userFirstTime", 'true');
    storage.commit();
  }


  // Defining routes for navigation
  var routes = <String, WidgetBuilder>{
    "/home":(BuildContext context) => Home(),
    "/postJob":(BuildContext context)=>PostJobs(),
    "/locationSearch":(BuildContext context)=>LocationSearch(),
    "/searchPage":(BuildContext context)=>SearchPage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "DasApp",
        routes: routes,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: appConfiguration.appColor
        ),
        home: init ? Scaffold(body:Container()) : firstTime  ? WelcomeScreen(login: (){
          setState(() {
            login = false;
            firstTime = false;
          });
          userFirstTime();
        },) : login ? Home() : Login()
    );
  }
}


