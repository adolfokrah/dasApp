import 'dart:convert';

import 'package:dasapp/changePassword.dart';
import 'package:dasapp/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import '../config.dart';
import 'package:share/share.dart';

import '../myReviews.dart';
import '../wallet.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override

  var menu =[
    {
      "key":"1",
      "title":"profile",
      "caption":"",
      "type":"none",
      "Icon":Icons.verified_user
    },
  {
  "key":"2",
  "title":"Privacy Policy",
  "caption":"Opens our privacy policy",
  "type":"link",
    "icon": Icons.verified_user,
    'link' : "https://dasexams.com/privacy-policy-2/"
  }
  ,{
      "key":"2",
      "title":"Reviews",
      "caption":"See what people say about you",
      "type":"page",
      "icon": Icons.stars,
    },{
  "key":"3",
  "title":"Terms and Conditions",
  "caption":"Opens our terms and conditions page",
  "type":"link",
      "icon": Icons.insert_drive_file,
      "link":"https://dasexams.com/terms-and-conditions/"
  },{
  "key":"4",
  "title":"Contact Support",
  "caption":"Ge help from our support team",
  "type":"link",
      "icon": Icons.help,
      "link":"https://dasexams.com/contact-support/"
  },
  {
  "key":"5",
  "title":"Complaints",
  "caption":"Let us know if you have any issue with a user",
  "type":"link",
    "icon": Icons.report,
    "link":"https://dasexams.com/complainants-page/"
  },
  {
  "key":"6",
  "title":"Become an affiliate",
  "caption":"refer and earn",
  "type":"page",
    "icon": Icons.supervised_user_circle
  },
  {
  "key":"7",
  "title":"Change password",
  "caption":"change your account's password",
  "type":"page",
    "icon": Icons.lock
  },
  {
  "key":"8",
  "title":"About",
  "type":"link",
    "caption":"",
    "icon": Icons.live_help,
    "link":"https://dasexams.com/dasapp"
  },{
  "key":"9",
  "title":"Rate",
  "caption":"Rate us on playstore",
  "type":"link",
      "icon": Icons.star,
      "link":"https://play.google.com/store/apps/details?id=com.dasapp"
  },{
  "key":"11",
  "title":"Logout",
  "caption":"",
      "type":"none",
      "icon": Icons.power_settings_new
  }
  ];
  var userDetailsState;
  var userId;
  var userType ='client';
  var loading = true;
  Config appConfiguration  = Config();
  GoogleSignIn _googleSignIn = GoogleSignIn();
  final facebookLogin = FacebookLogin();
  bool walletAdded = false;
  @override
  void initState(){
    getUserDetails();
  }

  getUserDetails()async{
    SharedPreferences storage = await SharedPreferences.getInstance();
    String userDetails = storage.getString('userDetails');
    print(userDetails);
    String user_id = "0";
    if(userDetails != null){
      var userDetailsArray = jsonDecode(userDetails);
      user_id = userDetailsArray['user_id'];
      setState(() {
        userId = user_id;
        userDetailsState = userDetailsArray;
        loading = false;
      });
      if(userDetailsArray['skills']!=""){

        var new_menu = menu;
        if(walletAdded == false){
          new_menu.insert( 1, {
            "key":"11",
            "title":"Wallet",
            "caption":"Manage and withdraw your earnings",
            "type":"none",
            "icon": Icons.account_balance_wallet
          });
        }
        setState(() {
          walletAdded = true;
          userType = "teacher";
          menu = new_menu;
        });
      }
    }
  }

  openUrl(link)async{
    await launch(link);
  }

  logout()async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: ()async{
                SharedPreferences storage = await SharedPreferences.getInstance();
                storage.remove("userDetails");
                _googleSignIn.signOut();
                facebookLogin.logOut();
                Phoenix.rebirth(context);
              },
            ),
          ],
        );
      },
    );
  }

  openProfile()async{
    var feedback = await Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => ProfilePage(teacher: userDetailsState)));
    if(feedback == true){
      getUserDetails();
    }
  }

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 80,
          child: AppBar(
            title: Text("Account"),
           
          ),
        ),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context,index)=>Divider(),
            itemCount: menu.length,
            itemBuilder: (context,index){

              if(index == 0 && loading == false){
                return InkWell(
                  onTap: (){
                    openProfile();
                  },
                  child: ListTile(
                    trailing: Icon(Icons.arrow_forward_ios,size:15),
                    leading:  Hero(
                      tag: 'user',
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(appConfiguration.usersImageFolder +userDetailsState['photo']),
                      ),
                    ),
                    title:Text('${userDetailsState['first_name']} ${userDetailsState['last_name']}',style: TextStyle(fontFamily: "Proxima")),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userDetailsState['email'],style: TextStyle(fontFamily: "Proxima")),
                        Text("Edit profile",style: TextStyle(fontFamily: "Proxima",fontSize: 12, color: Colors.blueAccent))
                      ],
                    ),
                  ),
                );
              }

              return InkWell(
                onTap: (){
                  if(menu[index]['type']=='link'){
                    openUrl(menu[index]['link']);
                  }
                  if(menu[index]['title']=='Logout'){
                    logout();
                  }
                  if(menu[index]['title'] == 'Change password'){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (BuildContext context) => ChangePassword(userId: userDetailsState['user_id'])));
                  }
                  if(menu[index]['title'] == 'Become an affiliate'){
                    Share.share('https://dasapp.page.link/?link=https://dasapp.biztrustgh.com/register?sponsor%3D${userDetailsState['email']}&apn=com.dasapp&st=Signup+with+dasapp&sd=Become+a+teacher+and+make+money+from+home+tutoring+with+dasapp.&si=https://dasapp.biztrustgh.com/ic_launcher_round.png');
                  }
                  if(menu[index]['title'] == 'Reviews'){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (BuildContext context) => MyReviews(teacher: userDetailsState)));
                  }

                  if(menu[index]['title'] == 'Wallet'){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (BuildContext context) => Wallet(userId: userId)));
                  }
                },
                child:  ListTile(
                  leading: Icon(menu[index]['icon']),
                  title: Text(userType == 'client' && menu[index]['title'] == 'Become an affiliate' ? "Share this app" : menu[index]['title'], style: TextStyle(fontFamily: "Proxima")),
                  subtitle: menu[index]['caption'] != '' ? Text(userType == 'client' && menu[index]['title'] == 'Become an affiliate' ? "Recommend dasapp to others" : menu[index]['caption'], style: TextStyle(fontFamily: "Proxima"),) : null,
                  trailing: menu[index]['type'] == 'link' ?Icon(Icons.open_in_new,size:15) : menu[index]['type'] == 'page' ? Icon(Icons.arrow_forward_ios,size:15) :null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
