import 'dart:convert';
import 'package:dasapp/tutorDetailsPage.dart';
import 'package:dasapp/tutorProposalDetails.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';

void main(){
  runApp(JobPaymentDetail());
}

class JobPaymentDetail extends StatefulWidget {
  final job;
  JobPaymentDetail({@required job}) : this.job = job;

  @override
  _JobPaymentDetailState createState() => _JobPaymentDetailState();
}

class _JobPaymentDetailState extends State<JobPaymentDetail> {
  Config appConfiguration = new Config();
  final _formKey = GlobalKey<FormState>();
  TextEditingController reviewController = TextEditingController();
  var proposals = [];
  var loading = true;
  var requesting = false;
  var email;
  var rating = 0;
  var job;
  var reviews;
  var sent = false;
  var userId;
  var jobId;
  var userType;
  var salary_break_down;
  var amountCharged;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      jobId = widget.job['job_id'];
    });
    fetchJobDetails();
    getUserDetails();
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

  //fetch job proposals
  void fetchJobDetails()async{
    setState(() {
      loading = true;
    });
    try{

      var url = '${appConfiguration.apiBaseUrl}fetchJobDetails';
      final request = await http.post(url,body:{'job_id':jobId});

      var data = jsonDecode(request.body);

      for(var i=0; i<data['reviews'].length; i++){
        if(userId != data['reviews'][i]['by_user']){
          setState(() {
            reviews = data['reviews'][i];
          });
          //break;
        }else{
          setState(() {
            sent = true;
          });
        }
      }

      if(request.statusCode == 200) {
        setState(() {
          loading = false;
          email= data['job_info']['email'];
          proposals = data['proposals'];
          job = data['job_info'];
          salary_break_down = data['salary_break_down'];
        });
      }
    }catch(e){
      print(e);
      Fluttertoast.showToast(
          msg: "Oops! an error occurred please try again later",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future<void> openProposal(i)async{
    if(job['awarded'] == 'yes'){
      Navigator.push(
          context, MaterialPageRoute(builder: (BuildContext context) => TutorDetailsPage(teacher:proposals[i] )));

      return;
    }
    proposals[i]['amountCharged'] = 0;
    proposals[i]['direct_hiring'] = 'no';
    var feedback = await  Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => TutorProposalDetails(teacher:proposals[i] )));
    if(feedback != null){
      fetchJobDetails();
    }
  }

  Future<void> releaseSalary()async{
    try{

      //if user is a teacher then request for payment

      String token = '${job['job_id']} ${email}';
      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      var url = '${appConfiguration.apiBaseUrl}releaseSalary?token='+stringToBase64.encode(token);
      await launch(url);
      
    }catch(e){
      print(e);
      Fluttertoast.showToast(
          msg: "Oops! an error occurred please try again later",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      setState(() {
        requesting = false;
      });
    }
  }

  Future<void> submitReview()async{
    try{
      if(_formKey.currentState.validate()){
        if(rating > 0){
          setState(() {
            requesting = true;
          });

          var url = '${appConfiguration.apiBaseUrl}rateUser';
          var data = {
            "byUser": userId.toString(),
            "job_id": job['job_id'].toString(),
            "to_user_id": job['to_user'].toString(),
            "rating": rating.toString(),
            "review": reviewController.text
          };

          final request = await http.post(url,body:data);
          if(request.statusCode == 200) {
            setState(() {
              requesting = false;
            });
          }

          Fluttertoast.showToast(
              msg: "Review Sent",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          ); fetchJobDetails();
        }else{

          Fluttertoast.showToast(
              msg: "Really? Your rating is highly needed",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      }
    }catch(e){
      print(e);
      Fluttertoast.showToast(
          msg: "Oops! an error occurred please try again later",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      setState(() {
        requesting = false;
      });
    }
  }

  closeJob()async{
    try{
      var url = '${appConfiguration.apiBaseUrl}closeJob';
      var data = {
        "job_id": job['job_id'].toString()
      };
      final request = await http.post(url,body:data);
      if(request.statusCode == 200) {
        setState(() {
          requesting = false;
        });
        if(mounted){
          fetchJobDetails();
        }
      }

      Fluttertoast.showToast(
          msg: "Job closed and no longer available",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }catch(e){
      print(e);
      Fluttertoast.showToast(
          msg: "Oops! an error occurred please try again later",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      setState(() {
        requesting = false;
      });
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
        isLoading: requesting,
        child: Scaffold(
            appBar: AppBar(
              title: Text("Proposals", style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color:Colors.white),),
              leading: IconButton(
                icon: Icon(Icons.arrow_back,color: Colors.white,),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              backgroundColor: appConfiguration.appColor,
              elevation: 0,
              actions: <Widget>[
              PopupMenuButton<int>(
              itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text("Refresh"),
                  ),
                 job['status'] != 'online' ? PopupMenuItem(
                   value: 4,
                   child: Text("Exit"),

                 ) :PopupMenuItem(
                   value: 2,
                   child: Text('Close job'),
                 )
                ],
                onSelected: (value){
                  if(value == 1){
                    fetchJobDetails();
                    return;
                  }else if(value == 2){
                    closeJob();
                  }

                },
              )]
            ),
            body: loading ? Align(alignment: Alignment.center,child: CircularProgressIndicator() ,): JobDetailsBody()
        ),
      ),
    );
  }


  Widget JobDetailsBody(){
      return ListView(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Color(0xffeeeeee),
                border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            padding: EdgeInsets.all(15),
            child: Text("Job details",style: TextStyle(fontFamily: "Proxima",fontSize: 16),),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(job['job_title'], style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,fontFamily: "Proxima"),),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(job['job_desc'], style: TextStyle(fontSize: 14,fontFamily: "Proxima"),),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(15,15,15,15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Budget",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,fontSize: 13),),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(job['payment_plan']+': ₵'+job['job_budget']+' - ₵ '+job['job_budget_to'],style: TextStyle(fontSize: 12,color: Color(0xfff535353)),),),
                Text("Duration",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,fontSize: 13),),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(job['duration'].replaceAll('LY',""),style: TextStyle(fontSize: 12,color: Color(0xfff535353)),),),
              ],

            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Color(0xffeeeeee),
                border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            padding: EdgeInsets.all(15),
            child: Text(job['awarded'] == 'yes' ? "Tutor's Cover letter" :job['direct_hiring'] == 'yes' ? "Your proposal" : "Proposals : ${proposals.length}",style: TextStyle(fontFamily: "Proxima",fontSize: 16),),
          ),
          Container(
            child: Proposals(),
          ),
          Container(
            child: Salary_break_down(),
          ),
          double.parse(job['amountChared']) > 0 && job['status'] == 'online'?
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: FlatButton(
                  padding: EdgeInsets.all(16),
                  onPressed: (){
                      releaseSalary();
                  },
                  color:appConfiguration.appColor,
                  child: Text("Release Salary for ${job['payment_date']}" ,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Proxima"),),
                ),
              )
              : Container(),
            loading ? Container() : ReviewBox(),
            loading ? Container() : SendReview()
        ],
      );
  }

  Widget Salary_break_down(){

    if(job['awarded'] == 'yes' && salary_break_down.length > 0){
      List <Widget> list = List<Widget>();
      var total = 0.0;
      for(var i=0; i<salary_break_down.length; i++) {
        if(salary_break_down[i]['paid'] == 'true'){
          total += double.parse(amountCharged);
        }
        list.add(TimelineTile(
          alignment: TimelineAlign.start,
//          isLast: i == (salary_break_down.length-1) ? true :false,
          beforeLineStyle: const LineStyle(
            color: Colors.black26,
            thickness: 2,
          ),
          afterLineStyle: const LineStyle(
            color: Colors.black26,
            thickness: 2,
          ),
          indicatorStyle: IndicatorStyle(
            width: 30,
            color: Colors.transparent,
            iconStyle: IconStyle(
              color: salary_break_down[i]['paid'] == 'true'  ? Colors.green : Colors.black26,
              iconData: Icons.check_circle,
            ),
          ),
          endChild: Padding(
            padding: EdgeInsets.fromLTRB(0,10,10,10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(salary_break_down[i]['payment_date'],style: TextStyle(fontFamily: "Proxima",fontSize: 13),),
                Text('GHS '+amountCharged.toString(),style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Proxima",fontSize: 13),),
              ],
            ),
          ),
        ));
      }
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Color(0xffeeeeee),
                  border: Border(bottom: BorderSide(color: Colors.black12))
              ),
              padding: EdgeInsets.all(15),
              child: Text("Salary Break Down",style: TextStyle(fontFamily: "Proxima",fontSize: 16),),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: list,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL',style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Proxima",fontSize: 13),),
                  Text('GHS '+total.toString(),style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Proxima",fontSize: 13),),
                ],
              ),
            )
          ]
      );
    }else{
      return Container();
    }
  }

  Widget ReviewBox(){
    if(job['status'] == 'past' && reviews != null){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Color(0xffeeeeee),
                border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            padding: EdgeInsets.all(15),
            child: Text("Review from Tutor",style: TextStyle(fontFamily: "Proxima",fontSize: 16),),
          ),
          Container(
            child: InkWell(
              onTap: () {
//                openProposal(i);
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(
                          appConfiguration.usersImageFolder +
                              reviews['photo']),
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
                                        Text(reviews['first_name'] + ' ' +
                                            reviews['last_name'].substring(0, 1) +
                                            '.', style: TextStyle(fontSize: 16,fontFamily: "Proxima"),),
                                        Container(
                                          child: reviews['verified'] == 'yes' ? Icon(Icons.verified_user,color: Colors.green,size:18,) : null,
                                        ),
                                        reviews['verified'] != 'yes' ? Icon(Icons.verified_user,size: 20,color:Colors.green,) : Container()
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                                      child: Row(
                                        children: <Widget>[
                                         getStars(int.parse(reviews['rating_given'])),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0,0,0,5),
                              child: Text(
                                reviews['review'],
                                style: TextStyle(color: Color(0xff4e4e4e),fontFamily: "Proxima"),
                              ),
                            ),

                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      );
    }else{
      return Container();
    }
  }

  Widget SendReview(){

    if(sent){
      return Container();
    }
    if(job['status'] == 'past') {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Color(0xffeeeeee),
                  border: Border(bottom: BorderSide(color: Colors.black12))
              ),
              padding: EdgeInsets.all(15),
              child: Text("Send Your Review",
                style: TextStyle(fontFamily: "Proxima", fontSize: 16),),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("How was your relationship with this tutor?",
                style: TextStyle(fontFamily: "Proxima",
                    fontWeight: FontWeight.bold,
                    fontSize: 13),),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                controller: reviewController,
                validator: (value) {
                  if (value.isEmpty) {
                    return "Your review is needed";
                  }
                  if (value.length < 50) {
                    return "your review is too short, min of 50 characters";
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Proxima',
                ),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: appConfiguration.appColor),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.black12),
                    )
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Text("Your rating is really needed", style: TextStyle(
                  fontFamily: "Proxima",
                  fontWeight: FontWeight.bold,
                  fontSize: 13),),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.star,
                      color: rating > 0 ? Colors.yellow : Colors.black12,),
                    onPressed: () {
                      setState(() {
                        rating = 1;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.star,
                      color: rating > 1 ? Colors.yellow : Colors.black12,),
                    onPressed: () {
                      setState(() {
                        rating = 2;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.star,
                      color: rating > 2 ? Colors.yellow : Colors.black12,),
                    onPressed: () {
                      setState(() {
                        rating = 3;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.star,
                      color: rating > 3 ? Colors.yellow : Colors.black12,),
                    onPressed: () {
                      setState(() {
                        rating = 4;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.star,
                      color: rating > 4 ? Colors.yellow : Colors.black12,),
                    onPressed: () {
                      setState(() {
                        rating = 5;
                      });
                    },
                  )
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: FlatButton(
                padding: EdgeInsets.all(16),
                onPressed: () {
                  submitReview();
                },
                color: appConfiguration.appColor,
                child: Text("Submit", style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Proxima"),),
              ),
            )
          ],
        ),
      );
    }else{
      return Container();
    }
  }


  Widget Proposals(){
    List <Widget> list = List<Widget>();
    if(job['awarded']=='yes'){
      setState(() {
        amountCharged = proposals[0]['original_charged'];
      });
    }
    for(var i=0; i<proposals.length; i++){

      list.add(
          Container(
            child: InkWell(
              onTap: () {
                openProposal(i);
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: 'teacher'+proposals[i]['user_id'],
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(
                            appConfiguration.usersImageFolder +
                                proposals[i]['photo']),
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
                                        Text(proposals[i]['first_name'] + ' ' +
                                            proposals[i]['last_name'].substring(0, 1) +
                                            '.', style: TextStyle(fontSize: 16,fontFamily: "Proxima"),),
                                        Container(
                                          child: proposals[i]['verified'] == 'yes' ? Icon(Icons.verified_user,color: Colors.green,size:18,) : null,
                                        ),
                                        proposals[i]['verified'] != 'yes' ? Icon(Icons.verified_user,size: 20,color:Colors.green,) : Container()
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
                                            ((proposals[i]['reviews'] + 1 / 100) *
                                                5).toStringAsFixed(2).toString()+'/5',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,fontFamily:"Proxima"),),
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10, 0, 0, 0),
                                            child: Text(
                                              proposals[i]['reviews'].toString() +
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
                                    Text("₵ " + proposals[i]['original_charged'] + "/" +
                                        job['payment_plan'].replaceAll('ly',"").toUpperCase(),
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
                                proposals[i]['message'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Color(0xff4e4e4e),fontFamily: "Proxima"),
                              ),
                            ),
                            job['awarded'] == 'yes' ? Container() : Text("See more",style: TextStyle(color:appConfiguration.appColor,fontSize: 13,fontFamily: "Proxma")),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child:  job['direct_hiring'] == 'yes' ? null : Row(
                                children: [
                                  Icon(Icons.location_on,size:15),
                                  Expanded(
                                    child: Text(
                                     proposals[i]['location'],
                                      style:TextStyle(fontFamily: "Proxima",color:Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              )
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
      if (i < (proposals.length - 1)) {
        list.add(Divider());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }
}
