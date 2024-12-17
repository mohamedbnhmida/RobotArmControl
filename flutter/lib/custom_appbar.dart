import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'custom_toolbarShape.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  late String title;
  CustomAppBar({required this.title});
  @override
  Size get preferredSize => Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
            color: Colors.transparent,
            child: Stack(fit: StackFit.loose, children: <Widget>[
              Container(
                  color: Color.fromARGB(255, 57, 127, 206),
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: CustomPaint(
                    painter: CustomToolbarShape(
                        lineColor: Color.fromARGB(255, 38, 78, 208)),
                  )),
              Align(
                  alignment: Alignment(0.1, 0.4),
                  child: Text(
                    title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500),
                  )),
 
            ])));
  }
}