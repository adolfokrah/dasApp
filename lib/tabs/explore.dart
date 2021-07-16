import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dasapp/searchPage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dasapp/config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../login.dart';
import '../tutorDetailsPage.dart';
import '../verifiedTeachers.dart';


class ExploreTab extends StatefulWidget {
  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  Config appConfiguarion = new Config();
  var popularCourses = [];
  var verfiedTeacers =[];
  var subjects =[];
  var loading = true;
  var user_type = "client";
  var user_id = '0';
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  List _colors = [
    [Color(0xFF28A0C2),Color(0xFF7ECCDE)],
    [Color(0XFFF6A742),Color(0XFFFAC76F)],
    [Color(0XFFFF5859),Color(0XFFF857A5)],
    [Color(0XFF695DF6),Color(0XFF427FF8)],
    [Color(0XFF692F92),Color(0XFF8339C6)],
    [Color(0XFFce55b6),Color(0XFFaf3797)],
    [Color(0XFF90d588),Color(0XFF53b648)],
    [Color(0XFFFF5859),Color(0XFFF857A5)],
    [Color(0XFF695DF6),Color(0XFF427FF8)],
    [Color(0XFFFF5859),Color(0XFFF857A5)]
  ];

  @override
  void initState(){
    super.initState();
    getPopularCourses();
  }

  Future getPopularCourses() async{
    try{

      String url = '${appConfiguarion.apiBaseUrl}fetchPopularCourses';
      var response = await http.get(Uri.parse(url));

      String url2 = '${appConfiguarion.apiBaseUrl}fetchProgramsToHome';
      SharedPreferences storage = await SharedPreferences.getInstance();
      String userDetails = storage.getString('userDetails');
      String manual = storage.getString("manual");
//      print(userDetails);
      String user_id = "0";
      if(!mounted) return;
      if(manual == null){
        WidgetsBinding.instance
            .addPostFrameCallback((_) => showInfoBox(context,appConfiguarion));
      }

      if(userDetails != null){
        var userDetailsArray = jsonDecode(userDetails);
        user_id = userDetailsArray['user_id'];
        setState(() {
          user_id = user_id;
        });
        if(userDetailsArray['skills']!=""){
          setState(() {
            user_type = "teacher";
          });
        }
      }

      var responseTwo = await http.post(Uri.parse(url2),body:{"userId": user_id});
      setState(() {
        verfiedTeacers = jsonDecode(responseTwo.body)['verified_teachers'];
        subjects = jsonDecode(responseTwo.body)["0"];
        popularCourses = jsonDecode(response.body);
        loading = false;
      });
    }catch(e){
      print(e);
    }
  }

  openSearchLocationBox(BuildContext context) async{
    final results = await Navigator.pushNamed(context, "/locationSearch");
    if(results != null){
      var arguments = jsonDecode(results);
      Navigator.push(
          context, MaterialPageRoute(builder: (BuildContext context) => SearchPage(lat:arguments['lat'],lng: arguments['lng'],user_id: arguments['user_id'],search: "",address:arguments['address'])));
    }
  }

  Future getUserLocation(search,to) async{
    try{

      //return;
      if(to == "search"){
        Navigator.push(
            context, MaterialPageRoute(builder: (BuildContext context) => SearchPage(lat:'',lng: '',user_id: user_id,search: search,address:'')));
      }else{
        Navigator.push(
            context, MaterialPageRoute(builder: (BuildContext context) => VerifiedTeachers()));
      }

      //openSearchPage(position.latitude, position.longitude);
    }catch(e){

    }
  }

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    getPopularCourses();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {

    return SmartRefresher(
     controller: _refreshController,
     enablePullDown: true,
     enablePullUp: true,
     footer:CustomFooter(
       builder: (BuildContext context,LoadStatus mode){
         return Container();
       }
     ),
     onRefresh: _onRefresh,
     child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
                        image: AssetImage("assets/images/home_banner.png"),
                        fit: BoxFit.cover,
                      )
                  ),
                  child: Align(
                    child: Text(
                        'What are you looking for',
                        style:TextStyle(
                          fontSize: 20,
                          fontFamily: 'Proxima',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(25.0),
                child: Container(
                  height: 47,
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xff5a5a5a),
                          offset: Offset(0.0, 0.4), //(x,y)
                          blurRadius: 3.2,
                        ),
                      ]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search,color: Color(0xff6e6e6e),),
                        onPressed: () {

                        },
                      ),
                      InkWell(
                        onTap: (){
                          getUserLocation("", "search");
                        },
                        child: Container(
                          height: 35,
                          child: Center(
                            child: Text(user_type == "teacher" ? "Search for teaching jobs" : "Search for home tutors",style: TextStyle(color:Colors.black45)),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.location_on,size:20,color: Color(0xff6e6e6e)),
                        onPressed: () {
                            openSearchLocationBox(context);
                        },
                      )
                    ],
                  ),
                ),

            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(loading ? loadingScreen(user_type) : exploreContent(popularCourses,verfiedTeacers,subjects,_colors,appConfiguarion,user_type,(search,to){
            getUserLocation(search,to);
            },context)),
          )
        ],
      ),
   );
  }

}
Future<void> showInfoBox(context,appConfiguration) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Align(alignment: Alignment.center,child: Text("New to dasApp?",style: TextStyle(fontFamily: "Proxima",fontSize: 20),),),
              Padding(padding: EdgeInsets.only(top:20),child: Text("Have a look at our user manual to get started",textAlign: TextAlign.center,),)
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("View",style: TextStyle(fontFamily: "Proxima",color: appConfiguration.appColor),),
            onPressed: (){
              Navigator.pop(context);
              launch("https://dasexams.com/dasapp/");
            },
          ),
          FlatButton(
            child: Text("Don't show this again",style: TextStyle(fontFamily: "Proxima",color: appConfiguration.appColor),),
            onPressed: ()async{
              Navigator.pop(context);
              SharedPreferences storage = await SharedPreferences.getInstance();
              storage.setString("manual", "true");
            },
          )
        ]
      );
    },
  );
}
//return the loading screen
List <Widget> loadingScreen(user_type){
  return[
  Padding(
    padding: EdgeInsets.all(18),
    child: Shimmer.fromColors(
      baseColor: Color(0xffe0e0e0),
      highlightColor: Color(0xffbdbdbd),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                width: 100.0,
                height: 18.0,
                color: Colors.white,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 18),
            ),
            Container(
              height: 140.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Container(
                      width: 200.0,
                      color: Colors.white
                  ),
                  Container(
                      width: 200.0,
                      color: Colors.white,
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: user_type == "teacher" ? [] : <Widget>[
                Container(
                  width: 100.0,
                  height: 18.0,
                  color: Colors.white,
                  margin: EdgeInsets.fromLTRB(0, 18, 0, 18),
                ),
                Container(
                  width: 50.0,
                  height: 18.0,
                  color: Colors.white,
                  margin: EdgeInsets.fromLTRB(0, 18, 0, 18),
                )
              ],
            ),
            Container(
              height: user_type == "teacher" ? 0 : 100,
              child: user_type == "teacher" ? null : ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Container(
                      width: 90.0,
                      color: Colors.white
                  ),
                  Container(
                    width: 90.0,
                    color: Colors.white,
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  ),
                  Container(
                    width: 90.0,
                    color: Colors.white,
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  ),
                  Container(
                    width: 90.0,
                    color: Colors.white,
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  )
                ],
              ),
            ),
            Container(
              width: 100.0,
              height: 18.0,
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0, 18, 0, 18),
            ),
            Container(
              height: 30.0,
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0,0, 0, 18),
            ),
            Container(
              height: 30.0,
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0,0, 0, 18),
            ),
            Container(
              height: 30.0,
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0,0, 0, 18),
            ),
            Container(
              height: 30.0,
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0,0, 0, 18),
            ),
            Container(
              height: 30.0,
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0,0, 0, 18),
            ),
            Container(
              height: 30.0,
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0,0, 0, 18),
            )
          ],
        ),
      ),
      ),
    ),
  ];
}

// return of list of the explorer page contents
List <Widget> exploreContent(popularCourses,verifiedTeachers,subjects,_colors,appConfiguration,user_type,onSearch,context){
  return [
    Padding(
      padding: EdgeInsets.all(popularCourses.length > 0 ? 18 : 0),
      child: popularCourses.length > 0 ? Text("Popular Subjects",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,fontFamily: "Proxima"),) : null,
    ),
    Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      height: popularCourses.length > 0 ? 140 :0,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: popularCourses.length, itemBuilder: (context, index) {
        return GestureDetector(
          onTap: ()=>{
            onSearch(popularCourses[index]['program_name'],'search')
          },
          child: Container(
            width: 200,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 1,
              child:Container(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Opacity(
                          opacity:0.3,
                          child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.black,
                              ),
                              child:Icon(Icons.edit,color: Colors.white,size: 15,)
                          ),
                        ),
                        Text(
                            popularCourses[index]['program_name'],
                            style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)
                        )
                      ],
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight, // 10% of the width, so there are ten blinds.
                    colors: _colors[index], // whitish to gray
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ),
    Padding(
        padding: EdgeInsets.all(user_type == "teacher" ? 0 : 18),
        child: user_type == "teacher"? null : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Verified Tutors",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,fontFamily: "Proxima"),),
            InkWell(
              onTap: (){
                 onSearch('','verified_tutors');
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.red,
                ),
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text("View all",style: TextStyle(color: Colors.white),)),
              ),
            )
          ],
        )
    ), Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        height: user_type == "teacher" ? 0 : 140,
        child: user_type == "teacher" ? null : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: verifiedTeachers.length, itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              Navigator.push(
                  context, MaterialPageRoute(builder: (BuildContext context) => TutorDetailsPage(teacher:verifiedTeachers[index] )));
            },
            child: Container(
              width: 100,
              child: Card(
                color: Colors.white,
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[

                    Container(
                      padding: EdgeInsets.all(0),
                      height:91,
                      width:100,
                      color: Colors.black12,
                      child:  Image.network(appConfiguration.usersImageFolder+verifiedTeachers[index]['photo'],height: 10,fit: BoxFit.fill,),
                      ),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(verifiedTeachers[index]['first_name'],overflow: TextOverflow.ellipsis,))
                  ],
                ),
              ),
            ),
          );
        }
        )
    ),
    Padding(
      padding: EdgeInsets.all(18),
      child: Text("All Subjects",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,fontFamily: "Proxima"),),
    ),
    for(var subject in subjects ) ListTile(
      onTap: (){
        onSearch(subject['name'],'search');
      },
      leading: Icon(Icons.edit),
      title: Text(subject['name'],style:TextStyle(fontFamily: "Proxima")),
      trailing: Icon(Icons.arrow_forward_ios,size: 15,),
    )

  ];


}
