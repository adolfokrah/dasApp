import 'dart:convert';

import 'package:dasapp/allTutorReviews.dart';
import 'package:dasapp/hireTutor.dart';
import 'package:dasapp/searchPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import 'config.dart';
import 'functions.dart';
import 'login.dart';

void main(){
  runApp(MyReviews());
}

class MyReviews extends StatefulWidget {
  final teacher;

  MyReviews({@required teacher}):this.teacher = teacher;
  @override
  _MyReviewsState createState() => _MyReviewsState();
}

class _MyReviewsState extends State<MyReviews> {
  Config appConfiguration = new Config();
  Functions functions = new Functions();
  bool top = false;
  ScrollController _scrollController = new ScrollController();

  var _teacherDetails;
  var _loading = true;

  @override
  void initState(){
    super.initState();
    setState(() {
      _teacherDetails = widget.teacher;
    });

    fetchTutorDetails(widget.teacher['user_id']);

    _scrollController.addListener(() {
      if(_scrollController.offset > 250){
        setState(() {
          top = true;
        });
      }else{
        setState(() {
          top = false;
        });
      }
    });

  }

  void fetchTutorDetails(_id) async{
    try{
      var url = '${appConfiguration.apiBaseUrl}fetchUserProfile';
      final request = await http.post(Uri.parse(url),body:{'userId':_id});
      if(request.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _loading = false;
        });
        var data = jsonDecode(request.body);
        setState(() {
          _teacherDetails = data['profile'];
        });
      }
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: appConfiguration.appColor
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("My Reviews", style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color:Colors.white),),
          backgroundColor: appConfiguration.appColor,
          elevation: 0,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: Colors.white,),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.only(top: 0, right:10, left: 10, bottom:10),
          children: [
            Column(
              children: [
                loadReveiws(_loading,_teacherDetails),
                displayReviews(_loading,_teacherDetails,appConfiguration,context)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget loadReveiws(_loading,_teacherDetails){
    if(_loading == true){
      return Shimmer.fromColors(
          baseColor: Color(0xffe0e0e0),
          highlightColor: Color(0xffbdbdbd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Container(
                height: 13,
                width: 100,
                margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:Colors.white,
                ),
              ),
              Container(
                height: 15,
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:Colors.white,
                ),
              ),
              Container(
                height: 15,
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:Colors.white,
                ),
              ),
              Container(
                height: 15,
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:Colors.white,
                ),
              )
            ],
          )
      );
    }

    List <Widget> list = List<Widget>();

    list.add(
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Text(_teacherDetails['reviews'].toString() +" reviews",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
        )
    );

    for(var i=0; i<_teacherDetails['ratings'].length; i++){
      var n = _teacherDetails['ratings']['${5-i} star'].toString();
      var value = double.parse(n) / 10;
      list.add(
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(

              children: <Widget>[
                Container(
                    width: 40,
                    child: Text('${5-i} star',style: TextStyle(color: Colors.black54,fontFamily: "Proxima"),)),
                Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.black12,
                        value:value,
                        valueColor: new AlwaysStoppedAnimation<Color>(Color(0xfff7b709)),
                      ),
                    )
                ),
                Container(
                    width: 40,
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(_teacherDetails['ratings']['${5-i} star'].toString(),style: TextStyle(color: Colors.black,fontFamily: "Proxima"),)))
              ],
            ),
          )
      );
    }
    list.add(
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        )
    );


    return Container(
      margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }
}

Widget displayReviews(_loading,_teacherDetails,appConfiguration,context){

  if(_loading == true){
    return Container();
  }

  List <Widget> list = List<Widget>();

  var max = _teacherDetails['user_reviews'].length < 5 ? _teacherDetails['user_reviews'].length : 5;



  for(var i=0; i < max ; i++){
    list.add(ReviewBox(_teacherDetails,i,appConfiguration));

    if (i < (_teacherDetails['user_reviews'].length - 1)) {
      list.add(Divider());
    }

  }

  if(_teacherDetails['user_reviews'].length > 1){
    list.add(
        InkWell(
          onTap: (){
            Navigator.push(
                context, MaterialPageRoute(builder: (BuildContext context) => AllTutorReviews(teacher:_teacherDetails)));
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.center,
              child: Text("SEE ALL REVIEWS",style:TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color: appConfiguration.appColor)),
            ),
          ),
        )
    );
  }
  return Container(
    margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    ),
  );
}

Widget ReviewBox(_teacherDetails,i,appConfiguration){

  var starsLength = int.parse(_teacherDetails['user_reviews'][i]['rating']);


  return (
      Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[ ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(appConfiguration.usersImageFolder+''+_teacherDetails['user_reviews'][i]['photo']),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(_teacherDetails['user_reviews'][i]['first_name'],style: TextStyle(fontFamily: "Proxima"),),
                  Text(_teacherDetails['user_reviews'][i]['date_posted'],style: TextStyle(fontSize: 14),)
                ],
              ),
            ),
              getStars(starsLength),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Text(_teacherDetails['user_reviews'][i]['message'],style: TextStyle(fontFamily: "Proxima"),)),
            ]
        ),
      )
  );

}

Widget getStars(starsLength){
  List <Widget> stars = List<Widget>();
  for(var x = 0; x<starsLength; x++){
    stars.add(Icon(Icons.star,color: Color(0xfff7b709),size:20,));
  }

  if(5-starsLength > 0){
    var newLength = 5-starsLength;
    for(var x = 0; x<newLength; x++){
      stars.add(Icon(Icons.star,color: Colors.black12,size:20,));
    }
  }

  return Row(
    children: stars,
  );
}

