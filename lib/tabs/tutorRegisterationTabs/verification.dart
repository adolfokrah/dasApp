import 'dart:convert';
import 'dart:io';

import 'package:dasapp/tutorRegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../config.dart';
import '../../locationSearch.dart';

void main(){
  runApp(Verification());
}

class Verification extends StatefulWidget {
  final Function nextPage;

  Verification({@required nextPage}) : this.nextPage = nextPage;
  @override
  _Verification createState() => _Verification();
}

class _Verification extends State<Verification> {
  var counter = 0;
  bool hidePass = true;


  final _formKey = GlobalKey<FormState>();

  Config appConfiguration = Config();
  File _imageFile;
  File _fullPhoto;
  File _id;
  var lat = "";
  var lng = "";
  var address = "";

  final ImagePicker _picker = ImagePicker();

  Future getImage(type) async {
    try{
      var  pickedFile;
      if(type == "photo"){
        pickedFile = await _picker.getImage(source: ImageSource.gallery, maxHeight: 300,maxWidth: 300);
      }else{
        pickedFile = await _picker.getImage(source: ImageSource.gallery);
      }

      setState(() {
         if( type == "photo"){
           _imageFile = File(pickedFile.path);
         }else if(type == "full_photo"){
           _fullPhoto = File(pickedFile.path);
         }else{
           _id = File(pickedFile.path);

         }
      });
    }catch(e){
      print(e);
    }
  }

  void validate(){

    if(!(_formKey.currentState.validate())){
      return;
    }
    if(_imageFile == null){
      Fluttertoast.showToast(
          msg: "Please add a proflie pic",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }

    var data ={
      'photo': _imageFile.path,
      'full_photo': _fullPhoto.path,
      'id': _id.path,
      'lat': lat,
      'lng': lng,
      'location': address
    };

    widget.nextPage(true,data);
  }

  Future getUserLocation()async{
    final results = await Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => LocationSearch()));
    if(results != null){
      var arguments = jsonDecode(results);
      setState(() {
        lat = arguments['lat'];
        lng = arguments['lng'];
        address = arguments['address'];
      });
    }
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
                      tick(true, appConfiguration),
                      spacer(),
                      line(appConfiguration,context),
                      tick(true, appConfiguration)
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                radius: 70,
                                backgroundImage:  _imageFile != null ? FileImage(_imageFile) : null,
                                child: InkWell(
                                    child:  Container(
                                      height: 90,
                                      width: 90,
                                      child: Icon(Icons.camera_alt),
                                    ) ,
                                    onTap:(){
                                      getImage('photo');
                                      //print('gettin image');
                                    }
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: TextFormField(
                                onTap: (){
                                  getUserLocation();
                                },
                                validator: (value){
                                  if(value.isEmpty){
                                    return "Please tell us where you live";
                                  }
                                  return null;
                                },
                                controller: TextEditingController(text: address),
                                readOnly: true,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.location_on),
                                    labelText: "Where do you live?",
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
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0,30,0,0),
                              child: Text("Please upload the following documents",style: TextStyle(fontFamily: "Proxima",fontSize: 19),),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: TextFormField(
                                onTap: (){
                                  getImage('full_photo');
                                },
                                controller: TextEditingController(text: _fullPhoto != null ?  _fullPhoto.path.split("/").last : ""),
                                validator: (value){
                                  if(value.isEmpty){
                                    return "Please attach your photo";
                                  }
                                  return null;
                                },
                                readOnly: true,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.file_upload),
                                    labelText: "Photo of your self",
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
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: TextFormField(
                                onTap: (){
                                  getImage('id');
                                },
                                validator: (value){
                                  if(value.isEmpty){
                                    return "Please attach ID photo";
                                  }
                                  return null;
                                },
                                controller: TextEditingController(text: _id != null ? _id.path.split("/").last : ""),
                                readOnly: true,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.file_upload),
                                    labelText: "Photo of your ID (passport, national ID or Voters ID)",
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
                                ),
                              ),
                            )
                          ],
                        ),
                    ),
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
                      child: Text("Done",style: TextStyle(color: Colors.white),),
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
