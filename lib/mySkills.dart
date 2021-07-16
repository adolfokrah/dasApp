import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

void main(){
  runApp(MySkills());
}
class MySkills extends StatefulWidget {
  final skills;
  MySkills ({@required skills}):this.skills = skills;
  @override
  _MySkillsState createState() => _MySkillsState();
}

class _MySkillsState extends State<MySkills> {
  Config appConfiguration = Config();
  List<String> skills = [];
  var courses = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var skillsArray = widget.skills.split(',');
    List<String> newSkills = [];
    skillsArray.forEach((skill){
      newSkills.add(skill.trim());
    });
    setState(() {
      skills = newSkills;
    });
  }
  getSkills()async{
    if(skills.length < 1){
      Fluttertoast.showToast(
          msg: "Please select the subjects you teach",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );

      return false;
    }

    Navigator.pop(context,skills.join(','));
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() async{getSkills(); return false;},
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: appConfiguration.appColor
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text("My Skills", style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color:Colors.white),),
            backgroundColor: appConfiguration.appColor,
            elevation: 0,
            leading: IconButton(
              onPressed: (){
                getSkills();
              },
              icon: Icon(Icons.close,color: Colors.white,),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: "What subject do you teach?",
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
                        var response = await http.post(Uri.parse(url),body:{'userId':"0"});
                        var popularCourses = jsonDecode(response.body);
                        setState(() {
                          courses = popularCourses["0"];
                        });
                        var results = [];
                        //print(popularCourses);
                        popularCourses["0"].forEach((course){
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

              ],
            )
          ),
        ),
      ),
    );
  }
}
