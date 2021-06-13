import 'package:dasapp/tutorDetailsPage.dart';
import 'package:flutter/material.dart';

import 'config.dart';

void main(){
  runApp(AllTutorReviews());
}
class AllTutorReviews extends StatefulWidget {
  final teacher;

  AllTutorReviews({@required teacher}):this.teacher = teacher;

  @override
  _AllTutorReviewsState createState() => _AllTutorReviewsState();
}

class _AllTutorReviewsState extends State<AllTutorReviews> {
  Config appConfiguration = new Config();
  var _teacherDetails;
  var reviews = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      _teacherDetails = widget.teacher;
      reviews = widget.teacher['user_reviews'];
    });

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: appConfiguration.appColor
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close,color: Colors.white,),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text("All reviews", style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold),),
        ),
        body:ListView.separated(
          itemCount: reviews.length,
          separatorBuilder: (context, index)=>Divider(),
          padding: EdgeInsets.all(20),
          itemBuilder: (context,index){
            return ReviewBox(_teacherDetails, index,appConfiguration);
          },
        ),
      ),
    );
  }
}
