import 'package:flutter/material.dart';
import 'config.dart';

class BottomIcon extends StatelessWidget {
  Config appConfiguration = new Config();

  final String _iconText;
  final IconData _icon;
  final EdgeInsetsGeometry _padding;
  final Color _color;
  final Function _onTap;

  BottomIcon({@required iconText, @required icon, padding, @required color, @required onTap})
      : this._iconText = iconText,
        this._icon = icon,
        this._padding = padding,
        this._color = color,
        this._onTap = onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding ?? EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              _onTap();
            },
            child: Column(
              children: <Widget>[
                Icon(
                  _icon,
                  color: _color,
                ),
                Text(
                  _iconText,
                  style: TextStyle(fontSize: 12,fontFamily: "Proxima", color:_color),
                )
              ],
            )
          )

        ],
      ),
    );
  }
}