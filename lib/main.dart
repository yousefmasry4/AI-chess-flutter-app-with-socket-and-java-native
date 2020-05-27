import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled8/board.dart';
import 'package:untitled8/splash.dart';
import 'package:untitled8/board_data.dart';
void main(){
  api_board.rerun();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      home: Splash(),
    );
  }
}