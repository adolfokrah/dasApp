import 'dart:async';
import 'dart:convert';

import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:date_time_format/date_time_format.dart';
import 'package:url_launcher/url_launcher.dart';


import 'config.dart';
import 'jobPaymentDetails.dart';
import 'jobPaymentDetailsTutor.dart';

void main(){
  runApp(ChatDetailsPage());
}



class ChatDetailsPage extends StatefulWidget {
  final chat;
  ChatDetailsPage({@required chat}): this.chat = chat;
  @override
  _ChatDetailsPageState createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  Config appConfiguration = Config();
  bool _loading = false;
  bool fetching = true;
  bool isShowSticker = false;
  bool sending = false;
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final dateTime = DateTime.now();
  var userId;
  var userType = 'client';
  var messages = [];
  Timer timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();

    var initializationSettingsAndroid =
    AndroidInitializationSettings('ic_stat_onesignal_default');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid,iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);


    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
      /// Display Notification, send null to not display, send notification to display
      event.complete(event.notification);
    });

    _notificationHandlers();

  }

  // void _handleNotificationReceived(OSNotification notification) {
  //
  // }


  void _notificationHandlers(){

    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
      var title = event.notification.title;
      var message = event.notification.body;
      var data = event.notification.additionalData;
      showNotification(title,message,data);

    });

  }

  Future onSelectNotification(String payload) {
    var data = jsonDecode(payload);
    if(data['chat'] != null){
      data['job_id'] = data['chat'];
      openChatPage(data);
    }
  }


  void openChatPage(data){
    if(data['chat'] == widget.chat['job_id']) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => ChatDetailsPage(chat:data)));
  }

  showNotification(title,message,data) async {
    if(data['chat'] == widget.chat['job_id']) return;
    var android = AndroidNotificationDetails(
        'id', 'channel ', 'description',
        sound: RawResourceAndroidNotificationSound('iphone_notification'),
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, title, message, platform,
        payload: jsonEncode(data));
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  //get userDetails
  void getUserDetails()async{
    SharedPreferences storage = await SharedPreferences.getInstance();
    String userDetails = storage.getString('userDetails');
    var userDetailsArray = jsonDecode(userDetails);
    setState(() {
      userId = userDetailsArray['user_id'];
    });

    if(userDetailsArray['skills'] != ""){
      setState(() {
        userType = 'teacher';
      });
    }
    fetchMessages();
    timer = Timer.periodic(new Duration(seconds: 3), (timer) {
      fetchMessages();
    });

  }

  fetchMessages()async{
    try{

      if(!mounted) {
        timer.cancel();
        return;
      }

      if(_loading) return;
      setState(() {
        _loading = true;
      });
      var url = '${appConfiguration.apiBaseUrl}fetchMessages';
      var data = {'user_id':userId,'job_id': widget.chat['job_id']};
      final request = await http.post(Uri.parse(url),body:data);

      if(request.statusCode == 200){
        var data = jsonDecode(request.body);
        if(!mounted) {
          timer.cancel();
          return;
        }
        var newMessages = [];
        var date = '';
        if(data.length > 0){
          data.forEach((message){

            newMessages.add(message);
            if(message['mdate_posted'] != date){
              date = message['mdate_posted'];
              var data = {
                'message':'',
                'mdate_posted': message['mdate_posted'],
                'time': ''
              };
              newMessages.add(data);
            }
          });
        }
        if(sending == false) {
          setState(() {
            _loading = false;
            fetching = false;
            messages = newMessages;
          });
        }
      }
    }catch(e) {
      print(e);
    }
  }



  sendMessage()async{
    if(messageController.text.isEmpty){
      return;
    }
    var message = messageController.text;
    RegExp exp = new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(message);

    matches.forEach((match) {
      var link = message.substring(match.start, match.end);
      if(!(link.contains('http'))){
        message = message.replaceAll(link, 'http://${link}');
      }
    });
    var newMessages = messages;

    var newMessage = {
      "c_id": 149,
      "sentby": userId,
      "teacher": 1,
      "employer": 35,
      "mstatus": "sending",
      "mdate_posted": "Today",
      "time": dateTime.format('h:i a').toUpperCase(),
      "job_id": 7,
      "message": message,
      "viewing": "2020-09-26 09:13:52",
      "key": 0,
      "job_title": "Job for Adolphus yaw Okrah, fullname: Karkhanis Parag",
      "photo": "8be9d5447b3a93aab33b5d6c2056d571.jpg",
      "user": "35",
      "lastSeen": "Last seen Friday, May 8th"
    };
    newMessages.insert(0,newMessage);

    setState(() {
      messages = newMessages;
      sending = true;
    });


    try{
      var url = '${appConfiguration.apiBaseUrl}sendMessage';
      var data = {'user_id':userId,'job_id': widget.chat['job_id'],'message': message};
      messageController.text = '';

      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
      
      final request = await http.post(Uri.parse(url),body:data);

      if(request.statusCode == 200){
        if(!mounted) {
          return;
        }
        print('message sent');
        setState(() {
          sending = false;
          _loading = false;
        });
      }
      fetchMessages();
    }catch(e) {
      if(!mounted) {
        return;
      }
      setState(() {
        sending = false;
        _loading = false;
      });
      fetchMessages();
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
      onWillPop: onBackPress,
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primaryColor: appConfiguration.appColor
          ),
          home:Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(appConfiguration.usersImageFolder +widget.chat['photo']),
                        ),
                      ),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(widget.chat['first_name']+" "+widget.chat['last_name'].substring(0,1)+'.', style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color:Colors.white),),
                         (!fetching ? Text(messages[0]['lastSeen']+'.', style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,fontSize: 12,color:Colors.white),) : Container())
                       ],
                     )
                    ],
                  ),
                  backgroundColor: appConfiguration.appColor,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back,color: Colors.white,),
                  ),
                ),
                body: ChatDetailsPageBody()
            ),

      ),
    );
  }

  Widget ChatDetailsPageBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: (){
            if(userType == 'client'){
              Navigator.push(
                  context, MaterialPageRoute(builder: (BuildContext context) => JobPaymentDetail(job:widget.chat)));
            }else{

              Navigator.push(
                  context, MaterialPageRoute(builder: (BuildContext context) => JobPaymentDetailTutor(job:widget.chat)));
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            color: Colors.black12,
            child: Text(widget.chat['job_title'] != null ? widget.chat['job_title'] : "")
          ),
        ),
        Expanded(
          child: fetching ? Align(alignment: Alignment.center,child: CircularProgressIndicator(),) : ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context,index){
              return Container(

                child: messages[index]['message'] == '' ? dateBox(messages[index]): messages[index]['sentby'] == userId ? senderLayout(messages[index]) : receiverLayout(messages[index]),
              );
            },
          ),
        ),
        // Input content
        widget.chat['status'] == 'online' ?  buildInput() : Container(),

        // Sticker
        (isShowSticker ? buildSticker() : Container()),
      ],
    );
  }

  Widget dateBox(messageData){
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(top:5,bottom: 5),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Text(messageData['mdate_posted'],style: TextStyle(color: Colors.white,fontFamily: "Proxima"),),
      ),
    );
  }
  Widget senderLayout(messageData){
    if(messageData['message'] == 'job_awarded'){
      return Container();
    }
    return Align(
        alignment: Alignment.topRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7
          ),
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Color(0xffb4b8e0),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)
                )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Linkify(text: messageData['message'],style: TextStyle(fontFamily: "Proxima"), onOpen: (link)async{
                  await launch(link.url);
                },),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Container(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right:6),
                          child: Text(messageData['time'],style: TextStyle(fontSize: 12),),
                        ),
                        messageData['mstatus'] =='seen' ? Icon(Icons.done_all,size:12,color: Colors.blue,) : messageData['mstatus'] =='sending' ? Icon(Icons.done,size: 12,color: Colors.black45) :
                        Icon(Icons.done_all,size: 12,color: Colors.black45)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

  Widget receiverLayout(messageData){
    if(messageData['message'] == 'job_awarded'){
      return Container();
    }
    return Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7
          ),
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(0xffebebf0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10)

              )
            ),
            child:  Linkify(text: messageData['message'],style: TextStyle(fontFamily: "Proxima"), onOpen: (link)async{
              await launch(link.url);
            },),
          ),
        )
    );
  }

//  Widget siteMetaData(data){
//
//    if(data['metaData'] == null){
//      return Container();
//    }
//
//    print(data['metaData'] );
//
//    return Container(
//      child: data['metaData'].title != null ?  Text(data['metaData'].title) : null,
//    );
//  }

  Widget buildSticker(){
    return EmojiPicker(
      rows: 3,
      columns: 7,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        messageController.text = messageController.text + emoji.emoji;
      },
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[

          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(isShowSticker ? Icons.keyboard : Icons.face),
                onPressed: () {
                    try{
                      setState(() {
                        isShowSticker = !isShowSticker;
                      });
                      FocusScope.of(context).unfocus();
                    }catch(e){
                    }
                },
                color: appConfiguration.appColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                controller: messageController,
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                onSubmitted: (value){
                  sendMessage();
                },
                onTap: (){
                  if(isShowSticker){
                    setState(() {
                      isShowSticker = false;
                    });
                  }
                },
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: appConfiguration.appColor,),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () {
                  sendMessage();
                },
                color: appConfiguration.appColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: appConfiguration.appColor, width: 0.5)),
          color: Colors.white),
    );
  }
}


