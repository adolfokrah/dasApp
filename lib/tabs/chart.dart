import 'dart:async';
import 'dart:convert';

import 'package:dasapp/chatDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  var messages = [];
  var userId;
  var userType = 'client';
  var _loading = false;
  var fetching = true;
  Config appConfiguration = Config();
  Timer timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }

  //search for teachers or jobs

  //get userDetails
  void getUserDetails()async{
    SharedPreferences storage = await SharedPreferences.getInstance();
    String userDetails = storage.getString('userDetails');
    var userDetailsArray = jsonDecode(userDetails);
    if(!mounted) return;
    setState(() {
      userId = userDetailsArray['user_id'];
    });
    if(userDetailsArray['skills'] != ""){
      setState(() {
        userType = 'teacher';
      });
    }
    timer = Timer.periodic(new Duration(seconds: 5), (timer) {
      fetchMyJobs();
    });

  }
  void fetchMyJobs() async{
    try{
      if(_loading) return;
      setState(() {
        _loading = true;
      });
      var url = '${appConfiguration.apiBaseUrl}fetchUserChats';
      var data = {'user_id':userId,'user_type': userType};
      final request = await http.post(url,body:data);

      if(request.statusCode == 200){
        var data = jsonDecode(request.body);
        if(!mounted) {
          return;
        }
        setState(() {
          _loading = false;
          messages = data;
          fetching = false;
        });

      }
    }catch(e){
      print(e);
//      Fluttertoast.showToast(
//          msg: "Connection failed, please try again later",
//          toastLength: Toast.LENGTH_LONG,
//          gravity: ToastGravity.BOTTOM,
//          timeInSecForIosWeb: 1,
//          backgroundColor: Colors.red,
//          textColor: Colors.white,
//          fontSize: 16.0
//      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          child: AppBar(
            title: Text("Messages"),
          ),
        ),
        Expanded(
          child: fetching ? Align(alignment: Alignment.center,child: CircularProgressIndicator(),) :messages.length < 1 ? Align(alignment: Alignment.center,child: Text("You have no messages",style: TextStyle(fontFamily: "Proxima"),),) :ListView.separated(
            itemCount: messages.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index){
              return InkWell(
                onTap: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (BuildContext context) => ChatDetailsPage(chat: messages[index])));
                },
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(appConfiguration.usersImageFolder +messages[index]['photo']),
                  ),
                  title: Text(messages[index]['first_name']+" "+messages[index]['last_name'].substring(0,1)+'.',style: TextStyle(fontFamily: "Proxima"),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        messages[index]['message'] == "job_awarded" ? "" : messages[index]['message'],maxLines: 1,
                        overflow: TextOverflow.ellipsis,style: TextStyle(fontFamily: "Proxima",color: messages[index]['sentby'] != userId && messages[index]['mstatus'] != 'seen' ? Colors.black : Colors.black45),),
                       messages[index]['sentby'] == userId ? messages[index]['mstatus'] =='seen' ? Icon(Icons.done_all,size:12,color: Colors.blue,) : messages[index]['mstatus'] =='sending' ? Icon(Icons.done,size: 12,color: Colors.black45) :
                       Icon(Icons.done_all,size: 12,color: Colors.black45) : Container()
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(messages[index]['sent_on'], style: TextStyle(fontFamily: "Proxima",fontSize: 11),),
                      Container(
                        child: messages[index]['unreads'] < 1 ? SizedBox() :Container(
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.only(top:5,bottom: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: appConfiguration.appColor,
                          ),
                          child: Text(messages[index]['unreads'].toString(),style: TextStyle(fontSize: 10, color: Colors.white),),
                        ),
                      ),
                      Text(messages[index]['lastSeen'],style: TextStyle(fontSize: 11, color: messages[index]['lastSeen'] == 'online' ? Colors.green : Colors.black),)
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
