
import 'package:dasapp/index.dart';
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;




void main(){
  //call the initial route (splashScreen)

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(Phoenix(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  Config appConfiguration = Config();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "DasApp",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: appConfiguration.appColor
      ),
      home:Index()
    );
  }
}


