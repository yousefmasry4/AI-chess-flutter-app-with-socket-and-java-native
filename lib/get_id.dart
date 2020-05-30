import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'board.dart';
import 'main.dart';
class get_id extends StatefulWidget {
  final id;

  const get_id({Key key,@required this.id}) : super(key: key);

  @override
  _get_idState createState() => _get_idState();
}


class _get_idState extends State<get_id> {

  final WebSocketChannel channel =
  IOWebSocketChannel.connect(
    Uri(
        scheme: "ws",
        host:"192.168.43.152",
        port: 8080,
        path: "/socket"),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    channel.sink.add("wait,"+widget.id);
    channel.stream.listen((event) {
        if(event == "gogogo"){
          channel.sink.close();
          Navigator. pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => board(me_or_he: true,id: widget.id,),
            ),
          );
        }
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.black,Colors.blueAccent])),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                    ),
                    Center(
                    child:Text(
                      'To invite someone to play, give this Code:',
                      style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                    ),

                  ),
                    Container(
                      height: 20,
                    ),
                    Center(
                      child:Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.id.toString(),
                            style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.grey,
                                color: Colors.black),
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            width: 10,
                            color: Colors.grey,
                          ),
                          GestureDetector(
                            child: Icon(Icons.content_copy,color: Colors.white,),
                            onLongPress: () {
                              Clipboard.setData(new ClipboardData(text: widget.id));

                            },
                          ),
                        ],
                      )

                    ),
                    Container(
                      height: 20,
                    ),
                    Center(
                      child:Text(
                        "The first person to come to this URL will play with you.",
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                      ),

                    ),
                    Container(
                      height: 20,
                    ),
                    Center(
                      child:Container(
                        child: Image.asset("images/load.gif"),
                      ),

                    ),
                  ],
                )
              ],
            )));
  }

}