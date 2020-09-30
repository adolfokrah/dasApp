import 'dart:convert';

import 'package:dasapp/searchPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location_permissions/location_permissions.dart';
import 'config.dart';

void main(){
  runApp(VerifiedTeachers());
}

class VerifiedTeachers extends StatefulWidget {
  @override
  _VerifiedTeachersState createState() => _VerifiedTeachersState();
}

class _VerifiedTeachersState extends State<VerifiedTeachers> {
  Config appConfiguration = new Config();

  var _loading = true;
  var _tutors = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchVerifiedTeachers();
  }

  void fetchVerifiedTeachers() async{
    try{
      PermissionStatus checkLocationPermission = await LocationPermissions().checkPermissionStatus();

      if(checkLocationPermission == 'denied'){
        PermissionStatus permission = await LocationPermissions().requestPermissions();
      }
      Fluttertoast.showToast(
          msg: "Fetching your location...",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black12,
          textColor: Colors.white,
          fontSize: 16.0
      );

      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      var lat = position.latitude.toString();
      var lng = position.longitude.toString();
      var url = '${appConfiguration.apiBaseUrl}fetchVerifiedTeachers';
      var request = await http.post(url,body:{'userId':"0",'lat':lat,'lng':lng});
      var data = jsonDecode(request.body);
      if(request.statusCode == 200) {
        setState(() {
          _loading = false;
          _tutors = data['verified_teachers'];
        });
      }

    }catch(e){
      //print(e);
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: appConfiguration.appColor
      ),
      home:Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.white,),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text("Verified Teachers", style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold),),
        ),
        body: ListView(
          children: _loading ? loadingWidget('client', false) : searchContent("client", _tutors, [], appConfiguration,context),
        ),
      )
    );
  }
}
