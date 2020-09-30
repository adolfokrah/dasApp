import 'dart:convert';

import 'package:dasapp/tutorRegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config.dart';
import 'package:http/http.dart' as http;

void main(){
  runApp(JobSkills());
}

class JobSkills extends StatefulWidget {
  final Function nextPage;

  JobSkills({@required nextPage}) : this.nextPage = nextPage;
  @override
  _JobSkills createState() => _JobSkills();
}

class _JobSkills extends State<JobSkills> {
  var counter = 0;
  bool hidePass = true;


  final _formKey = GlobalKey<FormState>();
  Config appConfiguration = Config();
  String currentText = "";
  List<String> skills = [];
  var courses = [];

  void validate(){

    if(skills.length == 0){
      Fluttertoast.showToast(
          msg: "Please select the subjects you want to be thought",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }

    widget.nextPage(true,skills);
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      child: Form(
        key: _formKey,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children :[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      tick(true, appConfiguration),
                      spacer(),
                      line(appConfiguration,context),
                      tick(true, appConfiguration)
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: "What subject do you want to be thought?",
                            labelStyle: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Proxima',
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
                        )
                    ),
                    suggestionsCallback: (pattern) async {

                      try {
                        if(courses.length == 0){
                          String url = '${appConfiguration.apiBaseUrl}fetchProgramsToHome';
                          var response = await http.post(url,body:{'userId':"0"});
                          var popularCourses = jsonDecode(response.body);
                          setState(() {
                            courses = popularCourses["0"];
                          });
                          var results = [];
                          popularCourses.forEach((course){
                            if(course['name'].toLowerCase().contains(pattern.toLowerCase())){
                              results.add(course);
                            }
                          });
                          return results;
                        }else{
                          var results = [];
                          courses.forEach((course){
                            if(course['name'].toLowerCase().contains(pattern.toLowerCase())){
                              results.add(course);
                            }
                          });
                          return results;
                        }
                      }catch(e){
                        print(e);
                        return [];
                      }

                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion['name'],style: TextStyle(fontFamily: "Proxima"),),
                        trailing: Icon(Icons.call_missed),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      if(!skills.contains(suggestion['name'])){
                        var new_skills = skills;
                        new_skills.add(suggestion['name']);
                        setState(() {
                          skills = new_skills;
                        });
                      }else{
                        Fluttertoast.showToast(
                            msg: "${suggestion['name']} already added",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: skills.length,
                    separatorBuilder: (context,index)=>Divider(),
                    itemBuilder: (context,index){
                      return ListTile(
                        leading: Icon(Icons.check_circle),
                        title: Text(skills[index],style: TextStyle(fontFamily: "Proxima"),),
                        trailing: IconButton(
                          onPressed: (){
                            var new_skills = skills;
                            new_skills.removeAt(index);
                            setState(() {
                              skills = new_skills;
                            });
                          },
                          icon: Icon(Icons.close),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: FlatButton(
                      padding: EdgeInsets.all(15),
                      onPressed: (){
                        validate();
                      },
                      color: appConfiguration.appColor,
                      child: Text("Post Job",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),
              ]
          ),

        ),
      ),
    );
  }

}
