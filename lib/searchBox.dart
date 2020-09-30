import 'package:flutter/material.dart';


class SearchBox extends StatefulWidget {
  final Function close;
  final Function search;
  final Function onSearch;
  final String initialValue;


  SearchBox({@required close,@required search,@required onSearch,@required initialValue}): this.close = close,this.search = search,this.onSearch = onSearch, this.initialValue = initialValue;
  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  static var _controller = TextEditingController();

  openSearchLocationBox(BuildContext context) async{
    final results = await Navigator.pushNamed(context, "/locationSearch");
    if(results != null){
      //print(results);
      widget.search(results);
    }
  }

  @override
  void initState(){
    setState(() {
      _controller.text = widget.initialValue;
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
        height: 40,
        margin: EdgeInsets.all(15),
        child: TextField(
          controller: _controller,
          onSubmitted: (value){
            widget.onSearch(value);
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 5, left: 15),
            prefixIcon: IconButton(
              icon: Icon(Icons.arrow_back,color: Color(0xff6e6e6e),),
              onPressed: () {
                widget.close();
              },
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.location_on,size:20),
              onPressed: () {
                openSearchLocationBox(context);
              },
            ),
            filled: true,
            fillColor: Colors.white,
            hintText: "Search for teachers and teaching jobs",
            hintStyle: TextStyle(
              fontSize: 15,
              fontFamily: 'Proxima',
            ),
            enabledBorder:OutlineInputBorder(
                borderSide:  BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(5)
            ),
            focusedBorder:OutlineInputBorder(
                borderSide:  BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(5)
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:  BorderSide(color: Colors.white),
            ),
          ),
        ),
      );

  }
}
