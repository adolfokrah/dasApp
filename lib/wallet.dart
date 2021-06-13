import 'dart:convert';

import 'package:dasapp/banks.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

void main(){
  runApp(Wallet());
}

class Wallet extends StatefulWidget {
  final userId;

  Wallet({@required userId}):this.userId = userId;
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  bool _loading = false;
  bool _fetching = true;
  Config appConfiguration = Config();
  var userSettlementAccountDetails;
  final _formKey = GlobalKey<FormState>();

  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  var bankData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchWalletDetails();
  }

  Future<void> fetchWalletDetails()async{
    try{
      var url = '${appConfiguration.apiBaseUrl}fetchUserTransactions';
      final request = await http.post(url,body:{'user_id':widget.userId});
      if(request.statusCode == 200) {

        if (!mounted) return;
        var data = jsonDecode(request.body);
        setState(() {
          _fetching = false;
          userSettlementAccountDetails = data['users_settlement_account'];
        });

        accountHolderNameController.text = data['users_settlement_account']['accounter_holder_name'];
        bankNameController.text = data['users_settlement_account']['bank_name'];
        accountNumberController.text = data['users_settlement_account']['bank_account_number'];

      }
    }catch(e){
      if (!mounted) return;
      setState(() {
        _fetching = false;
      });
      print(e);
    }
  }

  updateSettlementAccount()async{
    try{
      setState(() {
        _loading = true;
      });
      var url = '${appConfiguration.apiBaseUrl}update_user_settlement_account';
      var data = {
        "user_id": widget.userId,
        "bank_name": bankNameController.text,
        "holder_name": accountHolderNameController.text,
        "account_number": accountNumberController.text,
        "bank_code": bankData['code']
      };
      final request = await http.post(url,body:data);
      if(request.statusCode == 200) {

        if (!mounted) return;

        setState(() {
          _loading = false;
        });

        Fluttertoast.showToast(
            msg: "Account updated",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );


      }
    }catch(e){
      if(!mounted) return;
      Fluttertoast.showToast(
          msg: "Oops!, failed please try again",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );

      setState(() {
        _loading = false;
      });
      print(e);
    }
  }

  openBanksPage()async{
    var feedback = await  Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => Banks()));
    if(feedback != null){
//       print(feedback);
      if(!mounted) return;
      setState(() {
        bankData = feedback;
      });
      bankNameController.text = feedback['name'];
    }
  }

  Future<void> showInfoBox() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Are you sure you want to update your settlement account details?",style: TextStyle(fontFamily: "Proxima"),)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("No",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color: appConfiguration.appColor),),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Yes",style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color: appConfiguration.appColor),),
              onPressed: (){
                Navigator.pop(context);
                updateSettlementAccount();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primaryColor: appConfiguration.appColor
          ),
          home:LoadingOverlay(
            isLoading: _loading,
            child: Scaffold(
                appBar: AppBar(
                  title: Text("My Wallet", style: TextStyle(fontFamily: "Proxima",fontWeight: FontWeight.bold,color:Colors.white),),
                  backgroundColor: appConfiguration.appColor,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back,color: Colors.white,),
                  ),
                ),
                body: _fetching ? Align(alignment: Alignment.center, child: CircularProgressIndicator(),)  : walletBody()
            ),
          )
      ),
    );
  }

  Widget walletBody(){
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        Container(
          child: double.parse(userSettlementAccountDetails['balance'].replaceAll(',','')) < 1 ? null : Container(
            padding: EdgeInsets.all(15),
            child: Text("Your earnings will be transferred to your account on ${userSettlementAccountDetails['date_to_paid']}",style: TextStyle(fontFamily: "Proxima",),),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color:Color(0xffFFF4C6)
            ),
        ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text("Your current earnings",style: TextStyle(fontFamily: "Proxima",fontSize: 16)),
        ),
        Padding(
          padding: EdgeInsets.only(top:30),
          child: Text("GHS ${userSettlementAccountDetails['balance']}",style: TextStyle(fontFamily: "Proxima",fontSize: 35)),
        ),
        Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text("We will pay you through",style: TextStyle(fontFamily: "Proxima",fontSize: 14)),
        ),
        userSettlementAccountDetailsForm()
      ],
    );
  }

  Widget userSettlementAccountDetailsForm(){
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: accountHolderNameController,
              validator: (value){
                if(value.contains(new RegExp(r"[0-9.!#$%&'*+-/=?^_`{|}~]")) || value.isEmpty){
                  return 'Please your a valid name';
                }
                return null;
              },
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_circle),
                  labelText: "Account holder name",
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
            Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: TextFormField(
                controller: bankNameController,
                onTap: (){
                  openBanksPage();
                },
                validator: (value){
                  if(value.contains(new RegExp(r"[0-9.!#$%&'*+-/=?^_`{|}~]")) || value.isEmpty){
                    return 'Please your a valid name';
                  }
                  return null;
                },
                readOnly: true,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.home),
                    labelText: "Name of bank",
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
                  controller: accountNumberController,
                  keyboardType: TextInputType.number,
                  validator: (value){
                   if(value.isEmpty || value.length < 10){
                     return 'Please enter a valid account number';
                   }
                   return null;
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.security),
                    labelText: "Account Number",
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
            Container(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: FlatButton(
                  padding: EdgeInsets.all(15),
                  onPressed: (){
                    showInfoBox();
                  },
                  color: appConfiguration.appColor,
                  child: Text("Continue",style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
