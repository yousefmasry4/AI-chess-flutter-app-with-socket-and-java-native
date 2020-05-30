import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled8/board.dart';
import 'package:untitled8/splash.dart';
import 'package:untitled8/board_data.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  api_board.rerun();
 // final data=await http.get('https://raw.githubusercontent.com/yousefmasry4/AI-chess-flutter-app-with-socket-and-java-native/master/ip');
 // MyApp.ip=data.body.replaceAll("%0A", "");
  print(MyApp.ip);
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static String ip;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      home: Splash(),
    );
  }
}