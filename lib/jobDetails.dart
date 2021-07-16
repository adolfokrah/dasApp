import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:dasapp/proposeToJob.dart';
import 'package:dasapp/searchPage.dart';
import 'package:dasapp/tutorDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'config.dart';

void main(){
  runApp(JobDetails());
}

class JobDetails extends StatefulWidget {
  final job;

  JobDetails({@required job}):this.job = job;

  @override
  _JobDetailsState createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {
  Config appConfiguration = Config();
  var jobDetails;
  var loading = true;
  var totalProposals;
  bool applied = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      jobDetails = widget.job;
    });
    fetchJobDetails();
  }

  void fetchJobDetails()async{
    try{
      setState(() {
        loading = true;
      });
      var url = '${appConfiguration.apiBaseUrl}fetchJobDetails';
      final request = await http.post(Uri.parse(url),body:{'job_id':jobDetails['job_id']});
      var data = jsonDecode(request.body);
      if(request.statusCode == 200) {
        if(data.length < 1){
          Fluttertoast.showToast(
              msg: "Oops! Job not available",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.pop(context);
          return;
        }
        if(!mounted) return;
        setState(() {
          loading = false;
          jobDetails = data['job_info'];
          totalProposals = data['proposals'].length;
        });

        SharedPreferences storage = await SharedPreferences.getInstance();
        var userDetails = jsonDecode(storage.getString('userDetails'));

       for(var i =0; i<data['proposals'].length; i++){
         if(userDetails['user_id'] == data['proposals'][i]['user_id']){
           setState(() {
             applied = true;
           });
           break;
         }
       }
      }
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: jobDetails['job_title'],
      theme: ThemeData(
          primaryColor: appConfiguration.appColor
      ),
      home:Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: Colors.white,),
          ),
          title: Text("Job details",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold),),
          centerTitle: true,
            actions: <Widget>[
              PopupMenuButton<int>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text("Refresh"),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text('Share job'),
                  )
                ],
                onSelected: (value){
                  if(value == 1){
                    fetchJobDetails();
                    return;
                  }



                  var url = 'Hi, i found this cool teaching job on dasApp. I think you will like it, click on the link to view it now! \n https://dasapp.page.link/?link=https://dasapp.biztrustgh.com/job?job_id%3D${jobDetails['job_id']}%26job_title%3D${jobDetails['job_title'].replaceAll(' ','-')}&apn=com.dasapp&efr=?job_id=1';
                  Share.share(url);
//                  closeJob();
                },
              )]
        ),
        body: loading ? LoadingWidget() : JobDetailsBody()
      )
    );
  }

  Widget LoadingWidget(){
    return ListView(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Color(0xffeeeeee),
              border: Border(bottom: BorderSide(color: Colors.black12))
          ),
          padding: EdgeInsets.all(15),
          child: Text(jobDetails['job_title'],style: TextStyle(fontFamily: "Proxima",fontSize: 16),),
        ),
        Padding(
          padding: EdgeInsets.all(15),
          child: Shimmer.fromColors(
          baseColor: Color(0xffe0e0e0),
          highlightColor: Color(0xffbdbdbd),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 200,
                  height: 18,
                  color: Colors.white,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  width: 250,
                  height: 18,
                  color: Colors.white,
                ),
                Container(
                  width: 300,
                  height: 18,
                  color: Colors.white,
                )
              ],
            )
          )
      ),
        ),
      ]
    );
  }

  Widget JobDetailsBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Color(0xffeeeeee),
                border: Border(bottom: BorderSide(color: Colors.black12))
              ),
              padding: EdgeInsets.all(15),
              child: Text(jobDetails['job_title'],style: TextStyle(fontFamily: "Proxima",fontSize: 16),),
            ),
            institutionBox(jobDetails['institution']),
            Container(
              padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Client's budget",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,fontSize: 13),),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Text(jobDetails['payment_plan']+'LY: ₵'+jobDetails['job_budget']+' - ₵ '+jobDetails['job_budget_to'],style: TextStyle(fontSize: 12,color: Color(0xfff535353)),),),
                  Divider(),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Text(jobDetails['job_desc'],style: TextStyle(fontFamily: "Proxima",fontSize: 14),)),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text("Skills & expertise",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),)),
                  loadJobSkills(jobDetails['job_skills']),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Divider(),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                    child: Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                                height:20,
                                width: 200,
                                child: Text(jobDetails['date_posted'],style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),)),
                            Text('Posted on',style: TextStyle(color: Colors.black45,fontFamily: "Proxima"),)
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                                height:20,
                                child: Text(jobDetails['duration'],style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),)),
                            Text('Duration',style: TextStyle(color: Colors.black45,fontFamily: "Proxima"),)
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text('Location',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.location_on,size: 15,color: Colors.black45,),
                        Text(jobDetails['job_location'],style: TextStyle(color: Colors.black45,fontFamily: "Proxima"),),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Divider(),
                  ),
                  Text("Activity on this job",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Proposals:",style: TextStyle(fontFamily: "Proxima",color: Colors.black54),),
                        Text(totalProposals.toString(),style: TextStyle(fontFamily: "Proxima",color: Colors.black54))
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text("Please note, all proposals are accessible to clients on thier application page",style: TextStyle(fontFamily: "Proxima",color: Colors.black54),),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color:Color(0xffeeeeee),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Divider(),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Text("About this client",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),)),
                  Row(
                    children: <Widget>[
                      Icon(Icons.check_circle,color: Colors.green,size:18),
                    Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text("Payment method verified",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),))
                    ],
                  ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: getStars(jobDetails['rate'])),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text("${jobDetails['total_jobs'].toString()} jobs posted",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),)),
                  Text("Member since ${jobDetails['date_joined'].toString()}",style: TextStyle(fontSize: 13,color: Color(0xfff535353),fontFamily: "Proxima"),),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Divider(),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Text("Job link",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Color(0xfff535353),fontFamily: "Proxima"),)),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(text: "https://dasapp.page.link/?link=https://dasapp.biztrustgh.com/job?job_id%3D${jobDetails['job_id']}%26job_title%3D${jobDetails['job_title'].replaceAll(' ','-')}&apn=com.dasapp&efr=?job_id=1"),
                    style: TextStyle(fontFamily: "Proxima"),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xffeeeeee),
                        enabledBorder:OutlineInputBorder(
                            borderSide:  BorderSide(color: Color(0xfff3f3f3)),
                            borderRadius: BorderRadius.circular(2)
                        ),
                        focusedBorder:OutlineInputBorder(
                            borderSide:  BorderSide(color: Color(0xfff3f3f3)),
                            borderRadius: BorderRadius.circular(2)
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide:  BorderSide(color: Color(0xfff3f3f3)),
                        )
                    ),
                  ),
                  InkWell(
                    onTap: (){

                      var link = "https://dasapp.page.link/?link=https://dasapp.biztrustgh.com/job?job_id%3D${jobDetails['job_id']}%26job_title%3D${jobDetails['job_title'].replaceAll(' ','-')}&apn=com.dasapp&efr=?job_id=1";

                      FlutterClipboard.copy(link).then(( value ) =>
                          Fluttertoast.showToast(
                              msg: "Link copied",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black12,
                              textColor: Colors.white,
                              fontSize: 16.0
                          )
                      );


                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text("Copy link",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: appConfiguration.appColor,fontFamily: "Proxima"),),
                    ),
                  )
                ],
              ),
            )
          ],
      ),),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12)),
            color: Color(0xffeeeeee),
        ),
        padding: EdgeInsets.all(10),
        child: applied ?
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("You have already apply to this job",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold),),
            )
            : jobDetails['status'] != 'online' ? Padding(
          padding: EdgeInsets.all(10),
          child: Text("This job is no more available",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold),),
        ) : FlatButton(
          color: appConfiguration.appColor,
          padding: EdgeInsets.all(15),
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) => ProposeToJob(job: jobDetails)));
          },
          child: Text("Sumbit a Proposal",style: TextStyle(fontFamily:"Proxima",fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
        ),
      )
      ],
    );
  }

}


