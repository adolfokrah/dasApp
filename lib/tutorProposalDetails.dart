import 'dart:convert';

import 'package:dasapp/allTutorReviews.dart';
import 'package:dasapp/searchPage.dart';
import 'package:dasapp/tutorDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'config.dart';
import 'functions.dart';

void main(){
  runApp(TutorProposalDetails());
}

class TutorProposalDetails extends StatefulWidget {
  final teacher;

  TutorProposalDetails({@required teacher}):this.teacher = teacher;
  @override
  _TutorProposalDetails createState() => _TutorProposalDetails();
}

class _TutorProposalDetails extends State<TutorProposalDetails> {
  Config appConfiguration = new Config();
  Functions functions = new Functions();
  bool top = false;
  ScrollController _scrollController = new ScrollController();

  var _teacherDetails;
  var _loading = true;
  var offering = false;
  var userId;
  var userType;
  var amountCharged;
  var directHiring ='no';

  @override
  void initState(){
    super.initState();
    setState(() {
      _teacherDetails = widget.teacher;
      amountCharged = widget.teacher['amountCharged'];
      directHiring = widget.teacher['direct_hiring'];
    });

    fetchTutorDetails(_teacherDetails['user_id']);
    getUserDetails();
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

  void getUserDetails()async{

    SharedPreferences storage = await SharedPreferences.getInstance();
    String userDetails = storage.getString('userDetails');
    var user_id = jsonDecode(userDetails)['user_id'];
    var user_type = 'teacher';
    if(jsonDecode(userDetails)['skills'] == ''){
      user_type = 'client';
    }
    setState(() {
      userId = user_id;
      userType = user_type;
    });
  }

  void fetchTutorDetails(_id) async{
    try{
      var url = '${appConfiguration.apiBaseUrl}fetchUserProfile';
      final request = await http.post(url,body:{'userId':_id});

      if(request.statusCode == 200) {

        var data = jsonDecode(request.body);
        var teacher = _teacherDetails;
        teacher['ratings'] = data['profile']['ratings'];
        teacher['user_reviews'] = data['profile']['user_reviews'];
        setState(() {
          _loading = false;
          _teacherDetails =teacher;
        });
      }
    }catch(e){
      print(e);
    }
  }

  Future<void> offerJob(alert)async{
      if(alert){
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Are you sure you want to accept this proposal?'),
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
                  onPressed: () {
                    offerJob(false);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }

      try{
        setState(() {
          offering =true;
        });

        var url = '${appConfiguration.apiBaseUrl}acceptProposal';
        final request = await http.post(url,body:{'job_id':_teacherDetails['job_id'].toString(),'user_id':_teacherDetails['user_id'].toString(),'amount': _teacherDetails['original_charged']});

        if(request.statusCode == 200) {
          print(request.body);
          setState(() {
            offering = false;
          });

          Fluttertoast.showToast(
              msg: "Proposal accepted",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.pop(context,true);
        }


      }catch(e){
        setState(() {
          offering = false;
        });
        Fluttertoast.showToast(
            msg: "Oops! an error occurred please try again later",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
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
      home: LoadingOverlay(
        isLoading: offering,
        child: Scaffold(
          body:CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 300,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back,color: top ? Colors.white : Colors.black,),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                title: top ? Text(_teacherDetails['first_name']+" "+_teacherDetails['last_name'].substring(0,1)+'.',style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,),) : null,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Color(0xffF7F7F7),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 70, 0, 0),
                      child: Column(
                        children: <Widget>[
                          Hero(
                            tag: 'teacher'+_teacherDetails['user_id'],
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage: NetworkImage('${appConfiguration.usersImageFolder}${_teacherDetails['photo']}'),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(_teacherDetails['first_name']+' '+_teacherDetails['last_name'],style: TextStyle(fontSize: 18,fontFamily: "Proxima",fontWeight: FontWeight.bold),),
                                  Container(
                                    child: _teacherDetails['verified'] == 'yes' ? Icon(Icons.verified_user,color: Colors.green,) : null,
                                  )
                                ],
                              )

                          ),
                          Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0, 0, 5, 0),
                                      child: Icon(Icons.star,
                                        color: Color(0xfff7b709),
                                        size: 18,)),
                                  Text(
                                    ((_teacherDetails['reviews'] + 1 / 100) *
                                        5).toStringAsFixed(2).toString()+'/5',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,fontFamily:"Proxima"),),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(
                                        10, 0, 0, 0),
                                    child: Text(
                                      _teacherDetails['reviews'].toString() +
                                          " reviews",style: TextStyle(fontFamily: "Proxima"),),
                                  )
                                ],
                              )
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: userType == 'teacher' ? null :Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children : <Widget>[
                                  Text('₵ '+_teacherDetails['amount']+'/',style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text(_teacherDetails['Upayment_plan'],style: TextStyle(fontSize: 11,color:Colors.black54),)
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                // Use a delegate to build items as they're scrolled on screen.
                delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _teacherDetails['user_type'] == 'teacher' ? Text('Qualification',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),) : Container(),
                            _teacherDetails['user_type'] == 'teacher' ? Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                              child: Text(_teacherDetails['qualification'] == "" ? "N/A" : '${_teacherDetails['qualification'][0].toUpperCase()}${_teacherDetails['qualification'].substring(1).toLowerCase()}',style: TextStyle(fontFamily: "Proxima",fontSize: 15),),
                            ): Container(),
                            Text(userType == 'teacher' ? 'Amount Offered' : 'Amount charged',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child:  Text("GHS ${_teacherDetails['original_charged']}",style: TextStyle(fontSize: 15),),
                            ),
                            Text('Cover letter',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child:  Text(_teacherDetails['message'],style: TextStyle(fontFamily: "Proxima",fontSize: 15),),
                            ),
                            userType == 'client' ? Container(
                              margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child:  Text('Skills',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                            ) : Container(),
                            userType == 'client' ? loadJobSkills(_teacherDetails['skills']) : Container(),
                            loadReveiws(_loading,_teacherDetails),
                            displayReviews(_loading,_teacherDetails,appConfiguration,context),
                            amountCharged < 1 && directHiring == 'yes' && userType == 'teacher' || userType == 'client'  ? Container(
                              width: double.infinity,
                              child: FlatButton(
                                padding: EdgeInsets.all(16),
                                onPressed: (){
                                  offerJob(true);
                                },
                                color:appConfiguration.appColor,
                                child: Text("Accept Proposal",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Proxima"),),
                              ),
                            ) : Container()
                          ],
                        ),
                      )
                    ]
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget loadReveiws(_loading,_teacherDetails){
    if(_loading == true){
      return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Shimmer.fromColors(
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
        ),
      );
    }

    List <Widget> list = List<Widget>();
    list.add(
      Text('Rating & Reviews',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
    );
    list.add(
        Padding(
          padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
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
                    width: 45,
                    child: Text('${5-i} ${(5-i) == 1 ? 'star':'stars'}',style: TextStyle(color: Colors.black54,fontFamily: "Proxima"),)),
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
                  child: Text(_teacherDetails['user_reviews'][i]['review'],style: TextStyle(fontFamily: "Proxima"),)),
            ]
        ),
      )
  );

}


