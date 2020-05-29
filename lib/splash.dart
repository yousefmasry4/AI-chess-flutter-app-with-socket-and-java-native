import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'board.dart';
import 'get_id.dart';

class Splash extends StatefulWidget {
  @override
  _splash createState() => new _splash();
}

// ignore: camel_case_types
class _splash extends State<Splash> {
  static const platform = const MethodChannel('com.example.untitled8/helper');
  String _responseFromNativeCode = 'Waiting for Response...';
  String code;

  Future<void> responseFromNativeCode() async {
    String response = "";
    try {
      final String result = await platform.invokeMethod('helloFromNativeCode');
      response = result;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      _responseFromNativeCode = response;
      print(_responseFromNativeCode);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            child: Container(
              child: Stack(
                children: [
                  Container(
                    height: 450,
                    child: Image.asset("images/chess.gif"),
                  ),

                  Container(
                    height: 650,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment
                            .topCenter, // 10% of the width, so there are ten blinds.
                        colors: [
                          Colors.black,
                          Colors.black,
                          Colors.transparent
                        ], // whitish to gray
                        tileMode: TileMode
                            .repeated, // repeats the gradient over the canvas
                      ),
                    ),
                  ),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment
                            .bottomCenter, // 10% of the width, so there are ten blinds.
                        colors: [
                          Colors.black,
                          Colors.black,
                          Colors.transparent
                        ], // whitish to gray
                        tileMode: TileMode
                            .repeated, // repeats the gradient over the canvas
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 70),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: <Widget>[
                            // Stroked text as border.
                            Text(
                              'Sudo Chess',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.15,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 6
                                  ..color = Colors.grey[500],
                              ),
                            ),
                            // Solid text as fill.
                            Text(
                              'Sudo Chess',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.32,
                        ),
                        ProgressButton(
                          defaultWidget: Container(
                            width: 350,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal,
                                  Colors.teal[200],
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(5, 5),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Play with AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          progressWidget: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)),
                          color: Colors.transparent,
                          width: 350,
                          height: 70,
                          onPressed: () async {
                            return () {
                              responseFromNativeCode();
                              //TODO add ai core
                            };
                          },
                          animate: true,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        ProgressButton(
                          defaultWidget: Container(
                            width: 350,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal,
                                  Colors.teal[200],
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(5, 5),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Create room',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          progressWidget: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)),
                          color: Colors.transparent,
                          width: 350,
                          height: 70,
                          onPressed: ()  {
                            return () async {
                              final WebSocketChannel channel =
                                  IOWebSocketChannel.connect(
                                Uri(
                                    scheme: "ws",
                                    host: "192.168.43.152",
                                    port: 8080,
                                    path: "/socket"),
                              );
                              channel.sink.add("get_id");
                              channel.stream.asBroadcastStream().listen((event) {
                                print(event);
                                if (event != null && event[0] == 'c') {
                                  channel.sink.close();
                                  responseFromNativeCode();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => get_id(id:event.toString().split("c")[1],)),
                                  );
                                }
                              });

                            };
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 200,
                              child: TextFormField(
                                onChanged: (s){
                                  setState(() {
                                    code=s;
                                  });
                                },
                                style: TextStyle(color: Colors.green),
                                decoration: InputDecoration(
                                  labelText: "invitation code",
                                  labelStyle: TextStyle(
                                    color: Colors.green,
                                  ),
                                  fillColor: Colors.green,
                                  focusColor: Colors.green,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.green, width: 2.0),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.green, width: 2.0),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.green, width: 2.0),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  enabled: true,
                                ),
                                enabled: true,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            ProgressButton(
                              defaultWidget: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.teal,
                                      Colors.teal[200],
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(5, 5),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Go',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              progressWidget: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white)),
                              color: Colors.transparent,
                              width: 100,
                              height: 70,
                              onPressed: () async {
                                int score = await Future.delayed(
                                    const Duration(milliseconds: 3000),
                                    () => 42);
                                // After [onPressed], it will trigger animation running backwards, from end to beginning
                                return () {
                                  final WebSocketChannel channel =
                                  IOWebSocketChannel.connect(
                                    Uri(
                                        scheme: "ws",
                                        host: "192.168.43.152",
                                        port: 8080,
                                        path: "/socket"),
                                  );
                                  channel.sink.add("getinto,$code");
                                  channel.stream.asBroadcastStream().listen((event) {
                                    print(event);
                                    if(event == "gogogo"){
                                      channel.sink.close();
                                      Navigator. pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => board(me_or_he: true,id: code,),
                                        ),
                                      );
                                    }
                                  });
                                };
                              },
                              animate: true,
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
