import 'dart:convert';
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;

void main(){
  runApp(Banks());  
}

class Banks extends StatefulWidget {
  @override
  _BanksState createState() => _BanksState();
}

class _BanksState extends State<Banks> {
  Config appConfiguration = Config();
  bool _fetching = true;
  var banks;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchBanks();
  }


  Future<void> fetchBanks()async{
    try{
      setState(() {
        _fetching = true;
      });
      var url = '${appConfiguration.apiBaseUrl}getBanks';
      final request = await http.get(url);
      if(request.statusCode == 200) {

        if (!mounted) return;
        var data = jsonDecode(request.body);
        setState(() {
          _fetching = false;
          banks = data['data'];
        });
      }
    }catch(e){
      setState(() {
        _fetching = false;
      });
      print(e);
    }
  }

  close(data){
    Navigator.pop(context,data);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: appConfiguration.appColor
        ),
        home:Scaffold(
            appBar: AppBar(
              title: Text("Supported Banks", style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color:Colors.white),),
              backgroundColor: appConfiguration.appColor,
              elevation: 0,
              leading: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close,color: Colors.white,),
              ),
            ),
            body: _fetching ? Align(alignment: Alignment.center, child: CircularProgressIndicator(),)  : banksBody()
        )
    );
  }

  Widget banksBody(){
    return ListView.separated(
      itemCount: banks.length,
      separatorBuilder: (context,index)=>Divider(),
      itemBuilder: (context,index){
        return InkWell(
          onTap: (){
            close(banks[index]);
          },
          child: ListTile(
            leading: Icon(Icons.security),
            title: Text(banks[index]['name'],style: TextStyle(fontFamily: "Proxima"),),
          ),
        );
      },
    );
  }
}

