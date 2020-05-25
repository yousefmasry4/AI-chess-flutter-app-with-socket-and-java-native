import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled8/flutter_chess_board.dart';
import 'src/chess_board.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ignore: camel_case_types
class board extends StatefulWidget {
  @override
  _boardState createState() => new _boardState();
}

// ignore: camel_case_types
class _boardState extends State<board> {

  ChessBoardController c=new ChessBoardController();

  List<String> messages;
  String x="ss";
  @override
  // ignore: must_call_super
  void initState() {
    //Initializing the message list
    messages = List<String>();
    //Initializing the TextEditingController and ScrollController
    //Creating the socket

    //  WebSocketChannel channel =
    //  IOWebSocketChannel.connect('ws://192.168.1.5:8080/ws/572/eyppf4vh/websocket');



  }
  final WebSocketChannel channel = IOWebSocketChannel.connect(
    Uri(scheme: "ws", host: "192.168.1.5", port: 8080, path: "/socket"),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(Theme.of(context).platform == TargetPlatform.android ? 'android' : 'Android or other'),
      ),
      body:MediaQuery.of(context).size.width>650?
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("hello jo"),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ChessBoard(

                    onMove: (move) {
                      //  c.makeMove("a7","a6");
                      print(move);
                      channel.sink.add(move);
                    },
                    onCheck: (color) {
                      print(color);
                    },
                    onCheckMate: (color) {
                      print(color);
                    },
                    onDraw: () {},
                    size: MediaQuery.of(context).size.width,
                    enableUserMoves: true,
                    chessBoardController: c
                )
              ],
            ),
          ),
        ],
      )
          :Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(x),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ChessBoard(

                    onMove: (move) {
                      //  c.makeMove("a7","a6");
                      print(move);
                    },
                    onCheck: (color) {
                      print(color);
                    },
                    onCheckMate: (color) {
                      print(color);
                    },
                    onDraw: () {},
                    size: MediaQuery.of(context).size.width,
                    enableUserMoves: true,
                    chessBoardController: c
                )
              ],
            ),
          ),
        ],
      ),
    );

  }
}