import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

void main(){
  runApp(ProposeToJob());
}

class ProposeToJob extends StatefulWidget {
  final job;
  ProposeToJob({@required job}):this.job = job;
  @override
  _ProposeToJobState createState() => _ProposeToJobState();
}

class _ProposeToJobState extends State<ProposeToJob> {
  Config appConfiguration  = new Config();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  var totalAmountToBeCharged = 0.0;

  TextEditingController bidAmountController = TextEditingController();
  TextEditingController coverLetterController = TextEditingController();


  Future<void> submitProposal() async{
    try{
      if(_formKey.currentState.validate()){
          setState(() {
            _loading = true;
          });

          var url = '${appConfiguration.apiBaseUrl}proposeToJob';
          SharedPreferences storage = await SharedPreferences.getInstance();
          var userDetails = jsonDecode(storage.getString('userDetails'));


          var data ={
            "user_id": userDetails['user_id'],
            "job_id": widget.job['job_id'],
            "message": coverLetterController.text,
            "original_charged": totalAmountToBeCharged.toString(),
            "amount": widget.job['job_budget_to']
          };
          final request = await http.post(Uri.parse(url),body:data);
          //var data = jsonDecode(request.body);
          setState(() {
            _loading = false;
          });
          print(request.body);
          if(request.body =="error"){
            Fluttertoast.showToast(
                msg: "Oop!s, you have already apply to this job",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }else{
            Fluttertoast.showToast(
                msg: "Proposal submitted",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.pop(context);
          }

      }
    }catch(e){
      print(e);
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Submit proposal",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: appConfiguration.appColor
        ),
        home:LoadingOverlay(
          isLoading: _loading,
          child: Scaffold(
              appBar: AppBar(
                title: Text("Submit proposal", style: TextStyle(color: Colors.black,fontFamily: "Proxima",fontWeight: FontWeight.bold),),
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.black,),
                ),
              ),
              body:ProposeToJobBody()
          ),
        )
    );
  }


  Widget ProposeToJobBody(){
    return Form(
      key: _formKey,
      child: ListView(
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
            child: Text(widget.job['job_title'], style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,fontFamily: "Proxima"),),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(widget.job['job_desc'], style: TextStyle(fontSize: 15,fontFamily: "Proxima"),),
          ),
          Container(
            decoration: BoxDecoration(
                color: Color(0xffeeeeee),
                border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            padding: EdgeInsets.all(15),
            child: Text("Terms",style: TextStyle(fontFamily: "Proxima",fontSize: 16),),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Text("How much will you charge for this job", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,fontFamily: "Proxima"),),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(15,0,15,15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Client's budget",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,fontSize: 13),),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(widget.job['payment_plan']+'LY: ₵'+widget.job['job_budget']+' - ₵ '+widget.job['job_budget_to'],style: TextStyle(fontSize: 12,color: Color(0xfff535353)),),),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.56,
                      child: TextFormField(
                      controller: bidAmountController,
                        onChanged: (value){
                          try{
                            var amount = widget.job['commission_percentage'] * double.parse(bidAmountController.text) + double.parse(bidAmountController.text);

                             setState(() {
                               totalAmountToBeCharged = amount;
                             });
                          }catch(e){
                            //print(e);
                          }
                        },
                        validator: (value){
                          try {
                            if (int.parse(value) < int.parse(widget.job['job_budget'])) {
                              return "Your charge should be more than "+widget.job['job_budget'];
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
                            prefixText: "₵   ",
                            hintText: "eg. 246.00",
                            prefixStyle: TextStyle(
                              fontSize: 15,
                            ),
                            enabledBorder:OutlineInputBorder(
                                borderSide:  BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            focusedBorder:OutlineInputBorder(
                                borderSide:  BorderSide(color: appConfiguration.appColor),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:  BorderSide(color: Colors.black12),
                            )
                        ),
                      ),
                    ),
                    Text(' / '+widget.job['payment_plan'])
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text('Your charge + Das commission',style: TextStyle(fontFamily: "Proxima"))),
                Padding(
                  padding: EdgeInsets.only(top:10),
                  child: Text('GHS ${totalAmountToBeCharged}',style: TextStyle(fontFamily: "Proxima")),
                )
              ],

            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Color(0xffeeeeee),
                border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            padding: EdgeInsets.all(15),
            child: Text("Additional details",style: TextStyle(fontFamily: "Proxima",fontSize: 16),),
          ),
          Padding(
            padding: EdgeInsets.all(15),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cover letter",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,fontSize: 13),),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: TextFormField(
                    controller: coverLetterController,
                      validator: (value){
                        if(value.isEmpty){
                          return "Your cover letter is needed";
                        }
                        if(value.length < 100){
                          return "your cover letter is too short, min of 100 characters";
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
                          enabledBorder:OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(5)
                          ),
                          focusedBorder:OutlineInputBorder(
                              borderSide:  BorderSide(color: appConfiguration.appColor),
                              borderRadius: BorderRadius.circular(5)
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:  BorderSide(color: Colors.black12),
                          )
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: FlatButton(
                        padding: EdgeInsets.all(15),
                        onPressed: (){
                          submitProposal();
                        },
                        color: appConfiguration.appColor,
                        child: Text("Submit",style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  )
                ],
            )
          )
        ],
      ),
    );
  }

}

