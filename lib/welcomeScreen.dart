import 'package:flutter/material.dart';
import 'login.dart';
import 'welcomeScreenImages.dart';
import 'config.dart';

void main(){
  runApp(WelcomeScreen());
}

class WelcomeScreen extends StatefulWidget {

  final Function login;
  WelcomeScreen({@required login}):this.login = login;

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Config appConfiguration = Config();
  double currentPage = 0.0;
  final _pageViewController = new PageController();


  @override
  List<Widget> slides = items
      .map((item) => Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Image.asset(
              item['image'],
              fit: BoxFit.fitWidth,
              width: 220.0,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: <Widget>[
                  Text(item['header'],
                      style: TextStyle(
                          fontSize: 50.0,
                          fontWeight: FontWeight.w300,
                          color: Color(0XFF3F3D56),
                          height: 2.0)),
                  Text(
                    item['description'],
                    style: TextStyle(
                        color: Colors.grey,
                        letterSpacing: 1.2,
                        fontSize: 16.0,
                        height: 1.3),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          )
        ],
      )))
      .toList();

  List<Widget> indicator() => List<Widget>.generate(
      slides.length,
          (index) => Container(
        margin: EdgeInsets.symmetric(horizontal: 3.0),
        height: 10.0,
        width: 10.0,
        decoration: BoxDecoration(
            color: currentPage.round() == index
                ? Color(0XFF256075)
                : Color(0XFF256075).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.0)),
      ));


  Widget build(BuildContext context) {
    return MaterialApp(
        title: "DasApp",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: appConfiguration.appColor
        ),
        home: Scaffold(
          body: Container(
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: 80),
                    child: Image.asset("assets/images/logo2.png",width: 150,),
                  ),
                ),
                PageView.builder(
                  controller: _pageViewController,
                  itemCount: slides.length,
                  itemBuilder: (BuildContext context, int index) {
                    _pageViewController.addListener(() {
                      setState(() {
                        currentPage = _pageViewController.page;
                      });
                    });
                    return slides[index];
                  },
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 80.0),
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: indicator(),
                      ),
                    )
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(top: 70.0),
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20,right: 20),
                          child: FlatButton(
                            padding: EdgeInsets.all(16),
                            onPressed: (){
                                widget.login();
                            },
                            color:appConfiguration.appColor,
                            child: Text("Get started",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Proxima"),),
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),
        )
    );
  }
}
