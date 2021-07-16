import 'dart:convert';

import 'package:dasapp/locationSearch.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'config.dart';
import 'package:http/http.dart' as http;


void main(){
  runApp(HireTutor());
}

class HireTutor extends StatefulWidget {
  final tutor;
  HireTutor({@required tutor}):this.tutor = tutor;
  @override
  _HireTutorState createState() => _HireTutorState();
}

class _HireTutorState extends State<HireTutor> {
  Config appConfiguration = new Config();
  final _formKey = GlobalKey<FormState>();
  var lat = "";
  var lng = "";
  var user_id = "0";
  String paymentPlan = "Weekly";
  bool _loading = false;
  String duration = "Week";

  TextEditingController jobDescController = TextEditingController();
  TextEditingController budgetFromController = TextEditingController();
  TextEditingController budgetToController = TextEditingController();
  TextEditingController locationController  = TextEditingController();
  TextEditingController jobDurationController = TextEditingController();

  Future getJobLocation()async{
    final results = await Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => LocationSearch()));
    if(results != null){
      var arguments = jsonDecode(results);
      setState(() {
        lat = arguments['lat'];
        lng = arguments['lng'];
        user_id = arguments['user_id'];
      });
      locationController.text = arguments['address'];
    }
  }

  Future hireTutor()async{
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState.validate()) {
      setState(() {
        _loading = true;
      });

      try{
        String url = '${appConfiguration.apiBaseUrl}hireUser';
        var data = {
          "to_tutor": widget.tutor['user_id'],
          "job_desc": jobDescController.text,
          "payment_plan": paymentPlan.toLowerCase(),
          "budget_from": budgetFromController.text,
          "budget_to": budgetToController.text,
          "duration": jobDurationController.text+" "+paymentPlan.toUpperCase()+"(S)",
          "posted_by": user_id,
          "job_location": locationController.text,
          "lat": lat,
          "lng": lng
        };
        var response = await http.post(Uri.parse(url),body:data);

        setState(() {
          _loading = false;
        });

        Fluttertoast.showToast(
            msg: "Job invitation sent to tutor",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.pop(context);
      }catch(e){
        setState(() {
          _loading = false;
        });
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

  }

  getDuration(value){
    try{
      var d = paymentPlan.replaceAll("ly", "");
      var s = int.parse(value) > 1 ? "s" :'';
      setState(() {
        duration = d+s;
      });
    }catch(e){
      setState(() {
        duration = paymentPlan.replaceAll("ly", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Hire Teacher",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
        primaryColor: appConfiguration.appColor
    ),
    home: LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
         appBar: AppBar(
           leading: IconButton(
             icon: Icon(Icons.arrow_back,color: Colors.white),
             onPressed: (){
               Navigator.pop(context);
             },
           ),
           title: Text("Hire Teacher",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color: Colors.white),),
         ),
        body: HireTutorBody(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: appConfiguration.appColor,
          child: IconButton(
            icon: Icon(Icons.send,color: Colors.white,),
            onPressed: (){
              hireTutor();
            },
          ),
        ),
      ),
    )
    );
  }

  Widget HireTutorBody(){
    return Form(
      key: _formKey,
      child: Container(
            child: ListView(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xffeeeeee),
                      border: Border(bottom: BorderSide(color: Colors.black12))
                  ),
                  padding: EdgeInsets.all(15),
                  child: Text("Offer ${widget.tutor['first_name']} a teaching job",style: TextStyle(fontFamily: "Proxima",fontSize: 16),),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: jobDescController,
                    validator: (value){
                      if(value.isEmpty){
                        return "Job description needed";
                      }
                      if(value.length < 100){
                        return "Job description is too short, min of 100 characters";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Proxima',
                    ),
                    decoration: InputDecoration(
                        hintText: "What's this job about?",
                        hintStyle: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Proxima',
                        ),
                        enabledBorder:UnderlineInputBorder(
                            borderSide:  BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(0)
                        ),
                        focusedBorder:UnderlineInputBorder(
                            borderSide:  BorderSide(color: appConfiguration.appColor),
                            borderRadius: BorderRadius.circular(0)
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:  BorderSide(color: Colors.black12),
                        )
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(10,10,10,0),
                    child: Text("What's your payment plan?",style: TextStyle(color: Colors.black54,fontFamily: "Proxima",fontSize: 20))),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: DropdownButton(
                    isExpanded: true,
                    value: paymentPlan,
//                  icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black,fontSize: 18,fontFamily: "Proxima"),
                    underline: Container(
                      height: 2,
                      color: Colors.black12,
                    ),onChanged: (String newValue) {
                  setState(() {
                    paymentPlan = newValue;
                  });
                  getDuration(jobDurationController.text);
                  },
                    items: <String>['Weekly', 'Monthly', 'Yearly']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(10,10,10,0),
                    child: Text("How long will this job take?",style: TextStyle(color: Colors.black54,fontFamily: "Proxima",fontSize: 20))),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: jobDurationController,
                    onChanged: (value){
                      getDuration(value);
                    },
                    validator: (value){
                      try {
                        if (int.parse(value) < 0) {
                          return "Duration should be more than 0";
                        }
                        return null;

                      }catch(e){
                        return "Please enter a valid amount";
                      }
                    },
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Proxima',
                    ),
                    decoration: InputDecoration(
                        suffixText:duration,
                        suffixStyle: TextStyle(color: Colors.black),
                        enabledBorder:UnderlineInputBorder(
                            borderSide:  BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(0)
                        ),
                        focusedBorder:UnderlineInputBorder(
                            borderSide:  BorderSide(color: appConfiguration.appColor),
                            borderRadius: BorderRadius.circular(0)
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:  BorderSide(color: Colors.black12),
                        )
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(10,10,10,0),
                    child: Text("What's your budget?",style: TextStyle(color: Colors.black54,fontFamily: "Proxima",fontSize: 20))),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: budgetFromController,
                    validator: (value){
                      try {


                        if(double.parse(value) < 50){
                          return "Your inital amount be more than 49";
                        }
                        return null;
                      }catch(e){
                      return "Please enter a valid amount";
                      }
                    },
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Proxima',
                    ),
                    decoration: InputDecoration(
                        prefixText: "GHS:  ",
                        prefixStyle: TextStyle(color: Colors.black),
                        hintText: "eg. 20.00",
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Proxima',
                        ),
                        enabledBorder:UnderlineInputBorder(
                            borderSide:  BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(0)
                        ),
                        focusedBorder:UnderlineInputBorder(
                            borderSide:  BorderSide(color: appConfiguration.appColor),
                            borderRadius: BorderRadius.circular(0)
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:  BorderSide(color: Colors.black12),
                        )
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(10,10,10,0),
                    child: Text("Where is the location of the job?",style: TextStyle(color: Colors.black54,fontFamily: "Proxima",fontSize: 20))),
                Padding(
                    padding: EdgeInsets.fromLTRB(10,10,10,20),
                    child: TextFormField(
                      onTap: (){
                        getJobLocation();
                      },
                      controller: locationController,
                      validator: (value){
                        if(value.isEmpty){
                          return "Enter job location";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Proxima',
                      ),
                      decoration: InputDecoration(
                          prefixIcon:Icon(Icons.location_on),
                          prefixStyle: TextStyle(color: Colors.black),
                          hintText: "Enter location",
                          hintStyle: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Proxima',
                          ),
                          enabledBorder:UnderlineInputBorder(
                              borderSide:  BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(0)
                          ),
                          focusedBorder:UnderlineInputBorder(
                              borderSide:  BorderSide(color: appConfiguration.appColor),
                              borderRadius: BorderRadius.circular(0)
                          ),
                          border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide:  BorderSide(color: Colors.black12),
                          )
                      ),
                    )
                ),
              ],
            )
      )
    );
  }
}
