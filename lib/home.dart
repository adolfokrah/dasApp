import 'dart:convert';

import 'package:dasapp/tutorDetailsPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'bottomNavigator.dart';
import 'jobDetails.dart';
import 'jobPaymentDetailsTutor.dart';
import 'tabs/explore.dart';
import 'tabs/chart.dart';
import 'tabs/myJobs.dart';
import 'tabs/account.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'chatDetailsPage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Config appConfiguration = new Config();
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final List <Widget> tabs = [ExploreTab(),Chat(),MyJobs(),Account()];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  int currentTabIndex = 0;
  var changed = false;
  var user_type = "client";
  var userId;

  @override
  void initState(){
    getUserDetails();
    initDynamicLinks();
    setupOneSignalNotification();
    OneSignal.shared.setNotificationReceivedHandler(_handleNotificationReceived);
    _notificationHandlers();

    var initializationSettingsAndroid =
    AndroidInitializationSettings('ic_stat_onesignal_default');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) {
    var data = jsonDecode(payload);
    if(data['chat'] != null){
      data['job_id'] = data['chat'];
      openChatPage(data);
    }else if(data['request'] != null){
      Navigator.push(
          context, MaterialPageRoute(builder: (BuildContext context) => JobPaymentDetailTutor(job:data)));
    }
  }


  void openChatPage(data){
    setState(() {
      currentTabIndex = 1;
    });
    Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => ChatDetailsPage(chat:data)));
  }

  void setupOneSignalNotification()async{
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.init(
        "980bcbe3-1cc2-49ed-816e-b68e2ff0f88d",
        iOSSettings: {
          OSiOSSettings.autoPrompt: false,
          OSiOSSettings.inAppLaunchUrl: false
        }
    );


    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.none);

    getplayerId();

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
//    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
  }

  void getplayerId()async{
    var status = await OneSignal.shared.getPermissionSubscriptionState();

    var playerId = status.subscriptionStatus.userId;

    try{
      String url = '${appConfiguration.apiBaseUrl}updateUserToken';
      var data = {
        "user_id": userId,
        "token":playerId
      };
      var response = await http.post(url,body:data);

    }catch(e){

    }
  }


  void _handleNotificationReceived(OSNotification notification) {

  }

  showNotification(title,message,data) async {
    var android = AndroidNotificationDetails(
        'id', 'channel ', 'description',
        sound: RawResourceAndroidNotificationSound('iphone_notification'),
        priority: Priority.High, importance: Importance.Max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, title, message, platform,
        payload: jsonEncode(data));
  }
  
  void _notificationHandlers(){

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification)async{
      var title = notification.payload.title;
      var message = notification.payload.body;
      var data = notification.payload.additionalData;
      showNotification(title,message,data);

    });



    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // will be called whenever a notification is opened/button pressed.

      try{
        var json = result.notification.payload.additionalData;

        if(json['chat'] != null){
          var data = {
            'job_id': json['chat'],
            'job_title': json['job_title'],
            'first_name': json['first_name'],
            'last_name': json['last_name'],
            'photo': json['photo']
          };
          openChatPage(data);
        }else if(json['request'] != null){
          Navigator.push(
              context, MaterialPageRoute(builder: (BuildContext context) => JobPaymentDetailTutor(job:json)));
        }
      }catch(e){
        print('error');
        print(e);
      }
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      // will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // will be called whenever the subscription changes
      //(ie. user gets registered with OneSignal and gets a user ID)
      getplayerId();

    });

    OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges emailChanges) {
      // will be called whenever then user's email subscription changes
      // (ie. OneSignal.setEmail(email) is called and the user gets registered
    });
  }

  void initDynamicLinks() async {
    await Firebase.initializeApp();
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;
          if (deepLink != null) {
            openPageFromUrl(deepLink);
          }
        },


        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);
        }
    );

    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
     openPageFromUrl(deepLink);
//      Navigator.pushNamed(context, deepLink.path);
    }
  }

  openPageFromUrl(deepLink){
    var link =  Uri.dataFromString(deepLink.toString());
    if(deepLink.path == '/job'){
      var jobId = link.queryParametersAll['job_id'][0];
      var jobTitle = link.queryParametersAll['job_title'][0];
      var data  = {
        'job_id': jobId,
        'job_title': jobTitle
      };
      if(user_type == 'client') return;
      Navigator.push(
          context, MaterialPageRoute(builder: (BuildContext context) => JobDetails(job:data )));
    }else if(deepLink.path == '/teacher'){
      var teacherId = link.queryParametersAll['id'][0];
      var teacherName = link.queryParametersAll['name'][0].split('-');
      var data  = {
        'user_id': teacherId,
        'first_name': teacherName[0],
        'last_name': teacherName[1],
      };
      if(user_type == 'teacher') return;
      Navigator.push(
          context, MaterialPageRoute(builder: (BuildContext context) => TutorDetailsPage(teacher:data )));
    }
  }


  void getUserDetails()async{
    try{
      SharedPreferences storage = await SharedPreferences.getInstance();
      String userDetails = storage.getString('userDetails');
      //storage.clear();
      if(userDetails != null){
        var userDetailsArray = jsonDecode(userDetails);
        setState(() {
          userId = userDetailsArray['user_id'];
        });
        if(userDetailsArray['skills']!=""){
          setState(() {
            user_type = "teacher";
          });
        }
      }
    }catch(e){

    }
  }

  Future<void> openPostJob()async{
    var feedback = await Navigator.pushNamed(context, '/postJob');
    if(feedback != null){
      setState(() {
        currentTabIndex = 2;
      });
    }else if(changed){
      setState(() {
        changed = false;
        currentTabIndex = 2;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        if(currentTabIndex > 0){
          setState(() {
            currentTabIndex = 0;
          });
          return false;
        }else{
          return true;
        }

      },
      child: Scaffold(
          body:IndexedStack(
            index: currentTabIndex,
            children: [ExploreTab(),Chat(),currentTabIndex == 2 ? MyJobs() : Container(),Account()],
          ),
          bottomNavigationBar: BottomTab(onTap:(index){
            if(index != currentTabIndex){
              setState(() {
                currentTabIndex = index;
              });
            }
          }, index: currentTabIndex),
          floatingActionButton: user_type == "teacher" ? null : FloatingActionButton(
            backgroundColor: appConfiguration.appColor,
            elevation: 4.0,
            child: Icon(Icons.add),
            onPressed: () {
              openPostJob();
              if(currentTabIndex == 2){
                setState(() {
                  currentTabIndex = 0;
                  changed = true;
                });
              }
            },
          ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
        ),
    );
  }
}


