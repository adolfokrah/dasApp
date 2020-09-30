import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class Functions{
  //check if user is logined in
  Future checkAuth(context,callback)async{
    SharedPreferences storage = await SharedPreferences.getInstance();
    String userDetails = storage.getString('userDetails');
    //storage.clear();
    if(userDetails != null){
      callback();
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Login()));

  }
}