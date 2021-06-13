import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dasapp/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LocationSearch extends StatelessWidget {
  Config appConfiguration = new Config();

  // Defining routes for navigation


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: appConfiguration.appColor
        ),
        home: Scaffold(
            body:SafeArea(
              child: LocationSearchBody(close:(){
                Navigator.pop(context);
              }, replace:(arguments){
                //print(arguments);


                var json = '{"lat":"'+arguments['lat'].toString()+'","lng":"'+arguments['lng'].toString()+'","user_id":"'+arguments['user_id'].toString()+'","address":"'+arguments['address']+'"}';
                Navigator.pop(context,json);


              }),
            )
        )
    );
  }
}

class LocationSearchBody extends StatefulWidget {
  var close;
  var replace;

  LocationSearchBody ({@required close,@required replace}):this.close = close,this.replace = replace;

  @override
  _LocationSearchBodyState createState() => _LocationSearchBodyState();
}

class _LocationSearchBodyState extends State<LocationSearchBody> {
  Config appConfiguration = new Config();
  static var _controller = TextEditingController();
  String search = "";
  var predictions = [];
  var _loading = false;

  //search location
  Future searchLocation(search) async{
    String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?location=5.5353293,-0.426658&components=country:gh&input='+search+'&radius=50&key='+appConfiguration.googleMapsApiKey;

    try {
      var response = await http.get(url);
      if (!mounted) return;
      setState(() {
        predictions = jsonDecode(response.body)['predictions'];
      });
    }catch(e){

    }
    

  }

  Future getLocationCordinates(place_id) async{
    try{
      setState(() {
        _loading = true;
      });
      String url = 'https://maps.googleapis.com/maps/api/geocode/json?place_id='+place_id+'&key='+appConfiguration.googleMapsApiKey;
      var response = await http.get(url);

      var results  = jsonDecode(response.body);

      var lat = results['results'][0]['geometry']['location']['lat'];
      var lng = results['results'][0]['geometry']['location']['lng'];
      var address = results['results'][0]['formatted_address'];
      openSearchPage(lat, lng, address);

      //print(response.statusCode);
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

  Future getUserLocation() async{
    try{

      setState(() {
        _loading = true;
      });
      PermissionStatus checkLocationPermission = await LocationPermissions().checkPermissionStatus();

      if(checkLocationPermission == 'denied'){
        PermissionStatus permission = await LocationPermissions().requestPermissions();
      }

      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      //print(position.longitude);


      var url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${appConfiguration.googleMapsApiKey}';
      var request = await http.get(url);
      if (!mounted) return;
      setState(() {
        _loading = false;
      });

      var results = jsonDecode(request.body);
      var address = results['results'][0]['formatted_address'];

      openSearchPage(position.latitude, position.longitude,address);
    }catch(e){
      print(e);
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  void openSearchPage(lat,lng,address) async{
    SharedPreferences storage = await SharedPreferences.getInstance();
    String userDetails = storage.getString('userDetails');
    String user_id = "0";
    if(userDetails != null){
      var userDetailsArray = jsonDecode(userDetails);
      user_id = userDetailsArray['user_id'];
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      search = "";
      _controller.clear();
    });

     var data = {"lat": lat,"lng":lng,"user_id": user_id,'address':address};
     widget.replace(data);

  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: (
            Column(
              children: <Widget>[
                Container(
                  height:70,
                  child: TextField(
                    controller: _controller,
                    onChanged: (e){
                      setState(() {
                        search = e;
                      });
                      searchLocation(e);
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: Icon(Icons.arrow_back,color: Color(0xff6e6e6e),),
                          onPressed: () {
                            setState(() {
                              search = "";
                              predictions =[];
                            });
                            _controller.clear();
                            widget.close();
                          },
                        ),
                        suffixIcon: search.length > 0 ? IconButton(
                          icon: Icon(Icons.close,color: Color(0xff6e6e6e),),
                          onPressed: (){
                            setState(() {
                              search = "";
                              predictions =[];
                            });
                            _controller.clear();
                          },
                        ): null,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Search here",
                        enabledBorder:OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        focusedBorder:OutlineInputBorder(
                            borderSide:  BorderSide(color: Colors.black12),
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
                  child: search.length > 0 ? null : ListTile(
                    leading: Icon(Icons.my_location,color:appConfiguration.appColor),
                    title: Text("My Location",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.w600,color: appConfiguration.appColor),),
                    onTap: (){
                       getUserLocation();
                    },
                  ),
                ),
                Expanded(
                    child:ListView.separated(
                      itemCount: predictions.length,
                      separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
                      itemBuilder: (context,index){
                        return Container(
                          child: ListTile(
                            onTap: (){
                              getLocationCordinates(predictions[index]['place_id']);
                            },
                            trailing: IconButton(
                                icon:Icon(Icons.call_made,color:Colors.black,size: 20,)
                            ),
                            leading: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.black12,
                              ),
                              child: Icon(Icons.location_on,size:20),
                            ),
                            title: Text(predictions[index]['structured_formatting']['main_text'],style: TextStyle(fontFamily: "Proxima"),),
                            subtitle: Text(predictions[index]['structured_formatting']['secondary_text'] ?? "",style: TextStyle(fontFamily: "secondary_text"),),
                          ),
                        );
                      },
                    )
                )
              ],
            )
        ),
      ),
    );
  }
}


