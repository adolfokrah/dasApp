import 'dart:convert';

import 'package:dasapp/jobDetails.dart';
import 'package:dasapp/tutorDetailsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dasapp/config.dart';
import 'package:dasapp/searchBox.dart';
import 'package:dasapp/locationSearch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchPage extends StatefulWidget {
  final lat;
  final lng;
  final user_id;
  final search;
  final _address;

  SearchPage({@required lat,@required lng,@required user_id,@required search,@required address}) : this.lat = lat,this.lng = lng, this.user_id = user_id,this.search=search,this._address = address;
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  Config appConfiguration = new Config();



  var user_type = "client";
  var _search  = "";
  var _loading = true;
  var _lat = "0";
  var _lng = "0";
  var _user_id = '0';
  var _tutors = [];
  var _initial = true;
  var _teachingJobs =[];
  var _locationAddress = "";


  @override
  void initState() {
    super.initState();
    setState(() {
      _search = widget.search;
      _locationAddress = widget._address;
    });
    getUserDetails();
  }

  // Defining routes for navigation
  var routes = <String, WidgetBuilder>{
    "/locationSearch":(BuildContext context)=>LocationSearch(),
  };

  //search for teachers or jobs
  void searchForTeacherJobs(lat,lng,search,userId) async{

      setState(() {
        _lat = lat;
        _lng = lng;
        _user_id = userId;
      });
      //print(lat+'--'+lng+'--'+userId+'--'+search);
      try{

        setState(() {
          _loading = true;
          _initial = false;
        });
        var url = '${appConfiguration.apiBaseUrl}fetchTeachersJobs';
        var data = {'userId':userId,'lat':lat,'lng':lng,'search':search};
        final request = await http.post(Uri.parse(url),body:data);
        if(request.statusCode == 200){
          if (!mounted) return;
          setState(() {
            _loading = false;
          });
          var data = jsonDecode(request.body);
          if(user_type == "client"){
            setState(() {
              _tutors = data[0];
            });
            //print(data[0]);
          }else{
            if (!mounted) return;
            setState(() {
              _teachingJobs = data[1];
            });
          }
        }
      }catch(e){
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


  void getUserDetails()async{
    try{
      SharedPreferences storage = await SharedPreferences.getInstance();
      String userDetails = storage.getString('userDetails');
      if(userDetails != null){
        var userDetailsArray = jsonDecode(userDetails);
        if(userDetailsArray['skills']!=""){
          if (!mounted) return;
          setState(() {
            user_type = "teacher";
          });
        }
      }



      if(widget.lat != ""){
        searchForTeacherJobs(widget.lat, widget.lng, widget.search, widget.user_id);
      }else{
        //get user location and search

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

        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        var url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${appConfiguration.googleMapsApiKey}';
        var request = await http.get(Uri.parse(url));


        var results = jsonDecode(request.body);
        var address = results['results'][0]['formatted_address'];
        if (!mounted) return;
        setState(() {
          _locationAddress = address;
        });

        searchForTeacherJobs(position.latitude.toString(), position.longitude.toString(), widget.search, widget.user_id);
      }
    }catch(e){

    }
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        routes: routes,
        debugShowCheckedModeBanner: false,
        title: user_type == "client" ? "Search for tutors" : "Search for jobs",
        theme: ThemeData(
            primaryColor: appConfiguration.appColor
        ),
        home: Scaffold(
           appBar: PreferredSize(
               preferredSize: Size.fromHeight(0.0),
               child: AppBar(
                 backgroundColor: appConfiguration.appColor,
                 brightness: Brightness.dark,
               )
           ),
            body:SafeArea(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        child: SearchBox(
                          initialValue: _search,
                          close: (){
                          Navigator.pop(context);
                        },search: (results){
                          var resultsArray = jsonDecode(results);
                          searchForTeacherJobs(resultsArray['lat'], resultsArray['lng'], _search, resultsArray['user_id']);
                          setState(() {
                            _locationAddress = resultsArray['address'];
                          });
                        },onSearch: (value){
                          searchForTeacherJobs(_lat, _lng, value, _user_id);
                          setState(() {
                            _search = value;
                          });
                        },),
                      ),
                    ),
                    floating: true,
                    pinned: true,
                    expandedHeight: 120,
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(65.0),
                      child: Container(
                          height: 40,
                          padding: EdgeInsets.fromLTRB(18, 0, 0, 0),
                          child:Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                      child: Text( user_type == "client" ? "Available Tutors" : "Teaching Jobs",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,fontSize: 16,color:Colors.white),)),
                                  Container(
                                    margin:EdgeInsets.fromLTRB(10, 0, 0, 10),
                                    width: 200,
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Chip(
                                        backgroundColor: Color(0xff0e3c72),
                                        avatar: Icon(Icons.location_on,color:Colors.white,size:17),
                                        label:Text(_locationAddress,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:TextStyle(
                                                fontFamily: "Proxima",
                                                color:Colors.white,
                                            ))
                                      ),
                                    ),
                                  )
                                ],
                              ))
                      ),
                    ),
                  ),
                  SliverList(
                    // Use a delegate to build items as they're scrolled on screen.
                    delegate: SliverChildListDelegate(
                        _loading  ? loadingWidget(user_type,_initial) : searchContent(user_type,_tutors,_teachingJobs,appConfiguration,context)
                    ),
                  )

                ],
              ),
            )
        )
    );
  }
}

List <Widget>searchContent(user_type,_tutors,_techingJobs,appConfiguration,context){

  List <Widget> list = List<Widget>();

  //diplay no  results found widget if  tutors and teaching jobs array is emtpy

  if(user_type == "teacher" && _techingJobs.length < 1 || user_type == "client" && _tutors.length < 1){
      list.add(
        Align(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
                child: Icon(Icons.error_outline,size: 200,color: Colors.black12,),
              ),
              Text('No Results Found!',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,fontFamily: "Proxima",color: Colors.black12),),
              Text('Try changing your location!',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,fontFamily: "Proxima",color: Colors.black12),)
            ],
          )
        )
      );
  }

  if(user_type == "teacher"){
    for(var i = 0; i<_techingJobs.length; i++) {
      list.add(
          Container(
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (BuildContext context) => JobDetails(job:_techingJobs[i] )));
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    institutionBox(_techingJobs[i]['instiution']),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: Text(_techingJobs[i]['job_title'],style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.w600,fontSize: 15,),),
                    ),
                    Text(_techingJobs[i]['payment_plan']+'LY: ₵'+_techingJobs[i]['job_budget']+' - ₵ '+_techingJobs[i]['job_budget_to'],style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Color(0xfff535353)),),
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
                                   child: Text(_techingJobs[i]['date_posted'],style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),)),
                               Text('Posted on',style: TextStyle(color: Colors.black45,fontFamily: "Proxima"),)
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                  height:20,
                                  child: Text(_techingJobs[i]['duration'],style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),)),
                              Text('Duration',style: TextStyle(color: Colors.black45,fontFamily: "Proxima"),)
                            ],
                          )
                        ],
                      ),
                    ),
                    Text(_techingJobs[i]['job_desc'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                      fontFamily: "Proxima",
                      fontSize:15
                    ),),
                    loadJobSkills(_techingJobs[i]['job_skills']),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.location_on,size: 15,color: Colors.black45,),
                          Expanded(
                            child: Text(_techingJobs[i]['job_location'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, style:TextStyle(
                              fontFamily: "Proxima"
                            )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
      );
      if (i < (_techingJobs.length - 1)) {
        list.add(Divider());
      }
    }

  }else{

    for(var i = 0; i<_tutors.length; i++) {
      list.add(
          Container(
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (BuildContext context) => TutorDetailsPage(teacher:_tutors[i] )));
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: <Widget>[
                    Hero(
                      tag: 'teacher'+_tutors[i]['user_id'],
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(
                            appConfiguration.usersImageFolder +
                                _tutors[i]['photo']),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                   Row(
                                     children: <Widget>[
                                       Text(_tutors[i]['first_name'] + ' ' +
                                           _tutors[i]['last_name'].substring(0, 1) +
                                           '.', style: TextStyle(fontSize: 16,fontFamily: "Proxima"),),
                                        Container(
                                          child: _tutors[i]['verified'] == 'yes' ? Icon(Icons.verified_user,color: Colors.green,size:18,) : null,
                                        )
                                     ],
                                   ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 0, 5, 0),
                                              child: Icon(Icons.star,
                                                color: Color(0xfff7b709),
                                                size: 18,)),
                                          Text(
                                            ((_tutors[i]['reviews'] + 1 / 100) *
                                                5).toStringAsFixed(2).toString()+'/5',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,fontFamily:"Proxima"),),
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10, 0, 0, 0),
                                            child: Text(
                                                _tutors[i]['reviews'].toString() +
                                                    " reviews",style: TextStyle(fontFamily: "Proxima"),),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text("₵ " + _tutors[i]['amount'] + "/" +
                                        _tutors[i]['Upayment_plan'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0,0,0,5),
                              child: Text(
                                _tutors[i]['about'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Color(0xff4e4e4e),fontFamily: "Proxima"),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(),
                                Text(
                                  _tutors[i]['distance'],
                                  style:TextStyle(fontFamily: "Proxima",color:Colors.black),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
      );

      if (i < (_tutors.length - 1)) {
        list.add(Divider());
      }
    }

  }


  return [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    )
  ];
}

loadJobSkills(job_skills){
  List <Widget> list = List<Widget>();
  var job_skills_array = job_skills.split(',');

  for(var i = 0; i<job_skills_array.length; i++){
    list.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Colors.black12,
        ),
        child: Text(job_skills_array[i].trim(),style: TextStyle(fontFamily: "Proxima", fontSize: 12),),
      )
    );
  }

  return Container(
    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
    child: Wrap(
      runSpacing: 5,
      children: list,
    ),
  );
}


Widget institutionBox(institution){
  if(institution == ""){
    return Container();
  }
  return Row(
    children: <Widget>[
      Container(
        color: Color(0xffce1d7c),
        width: 20,
        height: 20,
        margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
        child: Icon(Icons.school,color: Colors.white,size: 15,),
      ),
      Container(
          color: Color(0xffce1d7c),
          width: 100,
          height: 20,
          child: Padding(
              padding: EdgeInsets.all(3),
              child: Text("INSTITUTION", style: TextStyle(color:Colors.white,fontFamily: "Proxima",fontWeight: FontWeight.bold,fontSize: 12)))
      )
    ],
  );
}

List <Widget> loadingWidget(user_type,_initial){
  if(_initial == true){
    return [
    Align(
      alignment: Alignment.center,
      child: Column(
      children: <Widget>[
        Container(
        margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
        child: Icon(Icons.search,size: 200,color: Colors.black12,),
        ),
        Text('What are you looking for',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,fontFamily: "Proxima",color: Colors.black12),),

      ],)
      )
    ];
  }
  return [
    Padding(
      padding: EdgeInsets.all(0),
      child:Shimmer.fromColors(
        baseColor: Color(0xffe0e0e0),
        highlightColor: Color(0xffbdbdbd),
        child: Align(
        alignment: Alignment.topLeft,
        child: user_type == "client" ? listOfLoaders() : listOfLoadersJobs(),
    ),),
    )
  ];
}

Widget listOfLoadersJobs() {
  List <Widget> list = List<Widget>();
  for(var i = 0; i<7; i++){
    list.add(
      Container(
        margin: EdgeInsets.fromLTRB(16, 25, 16, 10),
        height: 100,
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white,
              )
            ),
            Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white,
                )
            ),
            Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                width: 250,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white,
                )
            )
          ],
        ),
      )
    );
    list.add(
        Container(
            height: 0.5,
            color:Colors.white
        )
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: list,
  );
}

Widget listOfLoaders(){
  List <Widget> list = List<Widget>();
  for(var i = 0; i<7; i++){
    list.add(
        Container(
          margin: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                  ),Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                  ),Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    width: 230,
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: list,
  );
}