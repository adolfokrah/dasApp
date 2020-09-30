import 'dart:convert';

import 'package:dasapp/tabs/postJobTabs/jobDetails.dart';
import 'package:dasapp/tabs/postJobTabs/skills.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;

import 'package:dasapp/config.dart';

void main(){
  runApp(PostJobs());
}

class PostJobs extends StatefulWidget {

  @override
  _PostJobs createState() => _PostJobs();
}

class _PostJobs extends State<PostJobs> {
  Config appConfiguration = Config();
  bool _loading = false;
  int currentTabIndex = 0;
  var skills;
  var jobDetails;

  void setNextPage(){
    setState(() {
      currentTabIndex +=1;
    });
  }

  Future postJob()async{
    // Validate returns true if the form is valid, or false
    // otherwise.

    setState(() {
      _loading = true;
    });

    try{
      String url = '${appConfiguration.apiBaseUrl}postJob';
      var data = jobDetails;
      data['skills'] = skills.join(',');
      var response = await http.post(url,body:data);
      setState(() {
        _loading = false;
      });

      Fluttertoast.showToast(
          msg: "Job posted successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
     //print(response.body);
      Navigator.pop(context,true);
    }catch(e){
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
                  title: Text("Post a Job", style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color:Colors.white),),
                  backgroundColor: appConfiguration.appColor,
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
                    icon: Icon(Icons.arrow_back,color: Colors.white,),
                  ),
                ),
                body: IndexedStack(
                  index: currentTabIndex,
                  children: [JobDetails(nextPage:(status,data){
                    if(status){
                      setState(() {
                        currentTabIndex +=1;
                        jobDetails = data;
                      });
                      //print(data);
                    }
                  }),JobSkills(nextPage:(status,data){
                    if(status){
                      setState(() {
                        skills = data;
                      });

                      postJob();
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
