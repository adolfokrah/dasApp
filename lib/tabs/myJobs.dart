import 'dart:convert';

import 'package:dasapp/jobPaymentDetails.dart';
import 'package:dasapp/searchPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../jobPaymentDetailsTutor.dart';

class MyJobs extends StatefulWidget {
  @override
  _MyJobsState createState() => _MyJobsState();
}


class _MyJobsState extends State<MyJobs> {
  int selectedMenu = 1;
  bool _loading = true;
  String status = "active";
  var jobs;
  Config appConfiguration = new Config();
  var userType = "client";
  var user_Id;
  var tstatus = "Accepted";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMyJobs(status);
  }

  //search for teachers or jobs
  void fetchMyJobs(status) async{
    SharedPreferences storage = await SharedPreferences.getInstance();
    String userDetails = storage.getString('userDetails');
    var userDetailsArray = jsonDecode(userDetails);
    var userId = userDetailsArray['user_id'];

    if(userDetailsArray['skills'] != ""){
      setState(() {
        userType = 'teacher';
        user_Id = userId;
      });
    }

    try{
      setState(() {
        _loading = true;
      });
      var url = '${appConfiguration.apiBaseUrl}fetchUserJobs';
      var data = {'user_id':userId,'action':status,'user_type': userType};
      final request = await http.post(Uri.parse(url),body:data);
      if(request.statusCode == 200){
        var data = jsonDecode(request.body);
        if(!mounted) return;
        setState(() {
          _loading = false;
          jobs = data;
        });

      }
    }catch(e){
      print(e);
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
    return Column(
      children:[ Container(
        height: 85,
        child: AppBar(
          title: Text(userType == "client" ? "My Jobs" : "My Proposals"),
          actions: <Widget>[
            PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text(userType == "client" ? "Active Jobs":"Accepted Proposals"),
              ),
              PopupMenuItem(
                value: 2,
                child: Text(userType == "client" ? "Due Payment":"Rejected Proposals"),
              ),
              PopupMenuItem(
                value: 3,
                child: Text(userType == "client" ? "Past Jobs":"Pending Proposals"),
              ),
              userType == 'client' ?
              PopupMenuItem(
                value: 4,
                child: Text(userType == "client" ? "Offered Jobs":"Pending Proposals"),
              ) : PopupMenuItem(
                value:  4,
                child: Text("Exit"),
              )
              ],
            initialValue: selectedMenu,
            onCanceled: () {
              print("You have canceled the menu.");
            },
            onSelected: (value) {
              if(value == 4 && userType == 'teacher'){
                return;
              }
              var nStatus = value == 1 ? "active" : value == 2 ? "due payment" : value == 4 ? "Offered" : "past";
              var tnstatus = '';
              if(userType == 'teacher'){
                tnstatus = value == 1 ? "Accepted" : value == 2 ? "Rejected" : "Pending";
              }
              setState(() {
                selectedMenu = value;
                status = nStatus;
                tstatus = tnstatus;
              });
              fetchMyJobs(nStatus);
            },
            )
          ],
        ),
      ),
        Expanded(
          child:  _loading ? ListView(children: loadingWidget("teacher", false),) : jobs.length < 1 ?  Column(
            children: <Widget>[
                Container(
                margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
                 child: Icon(Icons.error_outline,size: 200,color: Colors.black12,),
                ),
                Text(userType == 'client' ? 'No jobs Found!': "No proposals Found!",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,fontFamily: "Proxima",color: Colors.black12),),
              ],
            ) :
          ListView.separated(
            itemCount: jobs.length,
            separatorBuilder: (context,index)=>Divider(),
            itemBuilder: (context,index){
              return MyJobsBody(index);
            },
          ),
        )
      ],
    );

  }

  Widget MyJobsBody(i){
    jobs[i]['user_type'] = userType;
     return Container(
       child: InkWell(
         onTap: () {
           if(userType == 'client'){
             Navigator.push(
                 context, MaterialPageRoute(builder: (BuildContext context) => JobPaymentDetail(job:jobs[i] )));
           }else{
             if(status == 'due payment'){
               return;
             }
             
             Navigator.push(
                 context, MaterialPageRoute(builder: (BuildContext context) => JobPaymentDetailTutor(job:jobs[i] )));
           }
         },
         child: Padding(
           padding: EdgeInsets.fromLTRB(0, 10, 16, 0),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: <Widget>[
               statusBox(status),
               Padding(
                 padding: EdgeInsets.only(left: 15, right: 15),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Container(
                       margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                       child: Text(jobs[i]['job_title'],style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.w600,fontSize: 15,),),
                     ),
                     Text(jobs[i]['payment_plan'].toUpperCase()+': ₵'+jobs[i]['job_budget']+' - ₵ '+jobs[i]['job_budget_to'],style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Color(0xfff535353)),),
                     Container(
                       margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
                       child: Row(
                         children: <Widget>[
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: <Widget>[
                               SizedBox(
                                   height:20,
                                   width: 200,
                                   child: Text(jobs[i]['date_posted'],style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),)),
                               Text('Posted on',style: TextStyle(color: Colors.black45,fontFamily: "Proxima"),)
                             ],
                           ),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: <Widget>[
                               SizedBox(
                                   height:20,
                                   child: Text(jobs[i]['duration'],style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),)),
                               Text('Duration',style: TextStyle(color: Colors.black45,fontFamily: "Proxima"),)
                             ],
                           )
                         ],
                       ),
                     ),
                     Text(jobs[i]['job_desc'],
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                       style: TextStyle(
                           fontFamily: "Proxima",
                           fontSize:15
                       ),),
                     loadJobSkills(jobs[i]['job_skills']),
                     Container(
                       margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                       child: Row(
                         children: <Widget>[
                           Icon(Icons.location_on,size: 15,color: Colors.black45,),
                           Expanded(
                             child: Text(jobs[i]['job_location'],
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                                 style:TextStyle(
                                     fontFamily: "Proxima"
                                 )),
                           )
                         ],
                       ),
                     ),
                     userType == "client" ? Container(
                       margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                       child: Row(
                         children: <Widget>[
                           Text("Proposals: ",style:TextStyle(
                               fontFamily: "Proxima"
                           )),
                           Text(jobs[i]['proposals'].toString(),style:TextStyle(
                               fontFamily: "Proxima"
                           ))
                         ],
                       ),
                     ) : Container(),
                     status == "due payment" &&  userType == 'client' ? Container(
                       padding: EdgeInsets.fromLTRB(3, 3, 3, 3),
                       color: Colors.red,
                       child: Text("Next Payment Due ${jobs[i]['payment_date']}",style:TextStyle(
                           fontWeight: FontWeight.bold,
                           fontFamily: "Proxima",color: Colors.white,fontSize: 12
                       )),
                     ): Container()
                   ],
                 ),
               )
             ],
           ),
         ),
       ),
     );
  }

  Widget statusBox(status){
    return Container(
        color: status == 'past' ? Colors.black12 : status == 'active' ? Colors.blueAccent : Colors.red,
        height: 20,
        child: Padding(
            padding: EdgeInsets.fromLTRB(3, 3, 10, 3),
            child: Text( userType == 'client' ? status.toUpperCase() : tstatus.toUpperCase() , style: TextStyle(color:status == 'past' ? Colors.black : Colors.white,fontFamily: "Proxima",fontWeight: FontWeight.bold,fontSize: 12)))
    );
  }
}


