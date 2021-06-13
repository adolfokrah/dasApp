import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'bottomIcons.dart';


class BottomTab extends StatefulWidget {
  final Function _onTap;
  final index;

  BottomTab({@required onTap, @required index})
      : this._onTap = onTap, this.index = index;
  @override
  _BottomTabState createState() => _BottomTabState();
}

class _BottomTabState extends State<BottomTab> {
  Config appConfiguration = new Config();

  int _selectedIndex = 0;

  var user_type = "client";

  @override
  void initState() {
    // TODO: implement initState
   getUserDetails();
    super.initState();
    setState(() {
      _selectedIndex = widget.index;
    });
  }

  void getUserDetails()async {
    try {
      SharedPreferences storage = await SharedPreferences.getInstance();
      String userDetails = storage.getString('userDetails');
      if (userDetails != null) {
        var userDetailsArray = jsonDecode(userDetails);
        if (userDetailsArray['skills'] != "") {
          setState(() {
            user_type = "teacher";
          });
        }
      }
    } catch (e) {}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {



    return BottomAppBar(
      color: Colors.white,
      shape: CircularNotchedRectangle(),
      child: Container(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              BottomIcon(
                icon: Icons.search,
                iconText: "Explore",
                color: widget.index == 0 ? appConfiguration.appColor : appConfiguration.navItemColor,
                onTap: (){
                  _onItemTapped(0);
                  widget._onTap(0);
                },
              ),
              BottomIcon(
                padding: EdgeInsets.only(right: user_type == "client" ? 30 : 0),
                icon: Icons.message,
                iconText: "Messages",
                color: widget.index == 1 ? appConfiguration.appColor : appConfiguration.navItemColor,
                onTap: (){
                  _onItemTapped(1);
                  widget._onTap(1);
                },
              ),
              BottomIcon(
                padding: EdgeInsets.only(left: user_type == "client" ? 30 : 0),
                icon: user_type == 'client' ? Icons.call_to_action : Icons.insert_drive_file,
                iconText: user_type == "client" ? "My Jobs" :"My Proposals",
                color: widget.index  == 2 ? appConfiguration.appColor : appConfiguration.navItemColor,
                onTap: (){
                  _onItemTapped(2);
                  widget._onTap(2);
                },
              ),
              BottomIcon(
                icon: Icons.account_circle,
                iconText: "Account", color: widget.index  == 3 ? appConfiguration.appColor : appConfiguration.navItemColor,
                onTap: (){
                  _onItemTapped(3);
                  widget._onTap(3);
                },
              ),
            ],
          ),
        ),
      ),
    );


    return BottomNavigationBar(
      selectedItemColor: appConfiguration.appColor,
      unselectedItemColor: appConfiguration.navItemColor,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontFamily: "Proxima"
      ),
      unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontFamily: "Proxima"
      ),
      items: [
        BottomNavigationBarItem(
            icon:Icon(Icons.search),
            title: Text("Explore")
        ),
        BottomNavigationBarItem(
            icon:Icon(Icons.message),
            title: Text("Chat")
        ),
        BottomNavigationBarItem(
            icon:Icon(Icons.add_circle),
            title: Text("Post Job")
        ),
        BottomNavigationBarItem(
            icon:Icon(Icons.verified_user),
            title: Text("My Jobs")
        ),
        BottomNavigationBarItem(
            icon:Icon(Icons.account_circle),
            title: Text("Account")
        )
      ],
    );
  }
}
