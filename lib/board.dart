import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:untitled8/board_data.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'dart:async';

import 'main.dart';

class chess_out{
  int a=0,b=0,c=0,d=0,e=0,f=0;
}

class board extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final bool me_or_he;
  final id;


  // ignore: non_constant_identifier_names
  const board({Key key, this.me_or_he, this.id}) : super(key: key);
  @override
  _PlayGamePageState createState() => _PlayGamePageState(me_or_he);
}

class _PlayGamePageState extends State<board> with TickerProviderStateMixin {
  final WebSocketChannel channel =
  IOWebSocketChannel.connect(
    Uri(
        scheme: "ws",
        host: MyApp.ip,
        port: 8080,
        path: "/socket"),
  );
  chess_out my_chess_out=new chess_out();

  chess_out he_chess_out=new chess_out();

  int durationAnimationBox = 500;
  int durationAnimationBtnLongPress = 150;
  int durationAnimationBtnShortPress = 500;
  int durationAnimationIconWhenDrag = 150;
  int durationAnimationIconWhenRelease = 1000;

  // For long press btn
  AnimationController animControlBtnLongPress, animControlBox;
  Animation zoomIconLikeInBtn, tiltIconLikeInBtn, zoomTextLikeInBtn;
  Animation fadeInBox;
  Animation moveRightGroupIcon;
  Animation pushIconLikeUp,
      pushIconLoveUp,
      pushIconHahaUp,
      pushIconWowUp,
      pushIconSadUp,
      pushIconAngryUp;
  Animation zoomIconLike,
      zoomIconLove,
      zoomIconHaha,
      zoomIconWow,
      zoomIconSad,
      zoomIconAngry;

  // For short press btn
  AnimationController animControlBtnShortPress;
  Animation zoomIconLikeInBtn2, tiltIconLikeInBtn2;

  // For zoom icon when drag
  AnimationController animControlIconWhenDrag;
  AnimationController animControlIconWhenDragInside;
  AnimationController animControlIconWhenDragOutside;
  AnimationController animControlBoxWhenDragOutside;
  Animation zoomIconChosen, zoomIconNotChosen;
  Animation zoomIconWhenDragOutside;
  Animation zoomIconWhenDragInside;
  Animation zoomBoxWhenDragOutside;
  Animation zoomBoxIcon;

  // For jump icon when release
  AnimationController animControlIconWhenRelease;
  Animation zoomIconWhenRelease, moveUpIconWhenRelease;
  Animation moveLeftIconLikeWhenRelease,
      moveLeftIconLoveWhenRelease,
      moveLeftIconHahaWhenRelease,
      moveLeftIconWowWhenRelease,
      moveLeftIconSadWhenRelease,
      moveLeftIconAngryWhenRelease;

  Duration durationLongPress = Duration(milliseconds: 250);
  Timer holdTimer;
  bool isLongPress = false;
  bool isLiked = false;

  // 0 = nothing, 1 = like, 2 = love, 3 = haha, 4 = wow, 5 = sad, 6 = angry
  int whichIconUserChoose = 0;

  // 0 = nothing, 1 = like, 2 = love, 3 = haha, 4 = wow, 5 = sad, 6 = angry
  int currentIconFocus = 0;
  int previousIconFocus = 0;
  bool isDragging = false;
  bool isDraggingOutside = false;
  bool isJustDragInside = true;

  ChessBoardController controller;
  List<String> gameMoves = [];
  var flipBoardOnMove = true;

  static List<double> timeDelays = [1.0, 2.0, 3.0, 4.0, 5.0];
  int selectedIndex = 0;
  bool turn;
  _PlayGamePageState( this.turn);

  onSpeedSettingPress(int index) {
    timeDilation = timeDelays[index];
    setState(() {
      selectedIndex = index;
    });
  }
  int he_img=0;


  @override
  void initState() {
    super.initState();
   // my_chess_out.a=1;
    my_chess_out.b=2;
  //  my_chess_out.c=5;
    my_chess_out.d=1;
    my_chess_out.e=0;
    my_chess_out.f=8;

    // Button Like
    initAnimationBtnLike();

    // Box and Icons
    initAnimationBoxAndIcons();

    // Icon when drag
    initAnimationIconWhenDrag();

    // Icon when drag outside
    initAnimationIconWhenDragOutside();

    // Box when drag outside
    initAnimationBoxWhenDragOutside();

    // Icon when first drag
    initAnimationIconWhenDragInside();

    // Icon when release
    initAnimationIconWhenRelease();
    channel.sink.add(widget.me_or_he?"set_player1,${widget.id}":"set_player2,${widget.id}");
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller = ChessBoardController();
    channel.stream.listen((event) {

      print(event);
      var x = event.split(",");
      print("jjjjjjjjjj");
      print(x[0].toString().split("")[1]);
      if (event.toString().length == 6) {
        //     x[0]=x[0][0]+(9-int.parse(x[0].toString().split("")[1])).toString();
        //  x[1]=x[1][0]+(9-int.parse(x[1].toString().split("")[1])).toString();
        print(x[0]);
        controller.makeMove(x[1], x[2]);
        bool aa = !turn;
        setState(() {
          turn = aa;
          print("from server $event");
          print("and $x");
          print(turn);
        });
      }else if(event.toString().length == 2){
        setState(() {
          print("reaction from out $event");
          he_img=int.parse(event[1]);
        });
      }
    });


  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    channel.sink.close();
    animControlBtnLongPress.dispose();
    animControlBox.dispose();
    animControlIconWhenDrag.dispose();
    animControlIconWhenDragInside.dispose();
    animControlIconWhenDragOutside.dispose();
    animControlBoxWhenDragOutside.dispose();
    animControlIconWhenRelease.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("Play with a friend"),
          backgroundColor: Colors.transparent,
        ),

        body: Stack(
              children: <Widget>[
                Center(
                  child:RotatedBox(
                    quarterTurns: 5,
                    child: Image(
                    image: AssetImage('images/screen.jpg'),
                    fit: BoxFit.fitWidth,

                  ),
    )
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        _buildChessBoard(),
                        Visibility(
                          visible: !turn,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            color: Colors.transparent,
                          ),
                        ),

                      ],
                    ),



                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left:5,top:  MediaQuery.of(context).size.height-( MediaQuery.of(context).size.width -160)),
                  child: Row(
                    children: [
                      he_renderBtnLike(),
                      Padding(
                        padding: EdgeInsets.only(top: 30,left: 100,right: 30),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            he_chess_out.a>0?Column(
                              children: [
                                WhitePawn(size: 30),
                                he_chess_out.a>1?Text(
                                  "x"+he_chess_out.a.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                      backgroundColor:Colors.black12
                                  ),
                                ):Container(),
                              ],
                            ):Container(),
                            he_chess_out.b>0?Column(
                              children: [
                                WhiteKnight(size: 30),
                                he_chess_out.b>0?Text(
                                  "x"+he_chess_out.b.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                      backgroundColor:Colors.black12
                                  ),
                                ):Container(),
                              ],
                            ):Container(),
                            he_chess_out.c>0?Column(
                              children: [
                                WhiteBishop(size: 30),
                                he_chess_out.c>0?Text(
                                  "x"+he_chess_out.c.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                      backgroundColor:Colors.black12
                                  ),
                                ):Container(),
                              ],
                            ):Container(),
                            he_chess_out.d>0?Column(
                              children: [
                                WhiteRook(size: 30),
                                he_chess_out.d>0?Text(
                                  "x"+he_chess_out.d.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                      backgroundColor:Colors.black12
                                  ),
                                ):Container(),
                              ],
                            ):Container(),
                            he_chess_out.e>0?Column(
                              children: [
                                WhiteQueen(size: 30),
                                he_chess_out.e>0?Text(
                                  "x"+he_chess_out.e.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                      backgroundColor:Colors.black12
                                  ),
                                ):Container(),
                              ],
                            ):Container(),
                            he_chess_out.f>0?Column(
                              children: [
                                WhiteKing(size: 30),
                                he_chess_out.f>0?Text(
                                  "x"+he_chess_out.f.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                      backgroundColor:Colors.black12
                                  ),
                                ):Container(),
                              ],
                            ):Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30,left: 120,right: 30),
                  child:Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      my_chess_out.a>0?Column(
                        children: [
                          WhitePawn(size: 30),
                          my_chess_out.a>1?Text(
                            "x"+my_chess_out.a.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              backgroundColor:Colors.black12
                            ),
                          ):Container(),
                        ],
                      ):Container(),
                      my_chess_out.b>0?Column(
                        children: [
                          WhiteKnight(size: 30),
                          my_chess_out.b>0?Text(
                            "x"+my_chess_out.b.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                backgroundColor:Colors.black12
                            ),
                          ):Container(),
                        ],
                      ):Container(),
                      my_chess_out.c>0?Column(
                        children: [
                          WhiteBishop(size: 30),
                          my_chess_out.c>0?Text(
                            "x"+my_chess_out.c.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                backgroundColor:Colors.black12
                            ),
                          ):Container(),
                        ],
                      ):Container(),
                      my_chess_out.d>0?Column(
                        children: [
                          WhiteRook(size: 30),
                          my_chess_out.d>0?Text(
                            "x"+my_chess_out.d.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                backgroundColor:Colors.black12
                            ),
                          ):Container(),
                        ],
                      ):Container(),
                      my_chess_out.e>0?Column(
                        children: [
                          WhiteQueen(size: 30),
                          my_chess_out.e>0?Text(
                            "x"+my_chess_out.e.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                backgroundColor:Colors.black12
                            ),
                          ):Container(),
                        ],
                      ):Container(),
                      my_chess_out.f>0?Column(
                        children: [
                          WhiteKing(size: 30),
                          my_chess_out.f>0?Text(
                            "x"+my_chess_out.f.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                backgroundColor:Colors.black12
                            ),
                          ):Container(),
                        ],
                      ):Container(),
                    ],
                  ),
                ),

                GestureDetector(
                  child: Column(
                    children: <Widget>[
                      // Just a top space


                      // main content
                      Container(
                        child: Stack(
                          children: <Widget>[
                            // Box and icons
                            Stack(
                              children: <Widget>[
                                // Box
                                //      renderBox(),

                                // Icons
                                renderIcons(),
                              ],
                              alignment: Alignment.center,
                            ),

                            // Button like
                            renderBtnLike(),

                            // Icons when jump
                            // Icon like
                            whichIconUserChoose == 1 && !isDragging
                                ? Container(
                              child: Transform.scale(
                                child: Image.asset(
                                  'images/like.gif',
                                  width: 40.0,
                                  height: 40.0,
                                ),
                                scale: this.zoomIconWhenRelease.value,
                              ),
                              margin: EdgeInsets.only(
                                top: processTopPosition(this.moveUpIconWhenRelease.value),
                                left: this.moveLeftIconLikeWhenRelease.value,
                              ),
                            )
                                : Container(),

                            // Icon love
                            whichIconUserChoose == 2 && !isDragging
                                ? Container(
                              child: Transform.scale(
                                child: Image.asset(
                                  'images/love.gif',
                                  width: 40.0,
                                  height: 40.0,
                                ),
                                scale: this.zoomIconWhenRelease.value,
                              ),
                              margin: EdgeInsets.only(
                                top: processTopPosition(this.moveUpIconWhenRelease.value),
                                left: this.moveLeftIconLoveWhenRelease.value,
                              ),
                            )
                                : Container(),

                            // Icon haha
                            whichIconUserChoose == 3 && !isDragging
                                ? Container(
                              child: Transform.scale(
                                child: Image.asset(
                                  'images/haha.gif',
                                  width: 40.0,
                                  height: 40.0,
                                ),
                                scale: this.zoomIconWhenRelease.value,
                              ),
                              margin: EdgeInsets.only(
                                top: processTopPosition(this.moveUpIconWhenRelease.value),
                                left: this.moveLeftIconHahaWhenRelease.value,
                              ),
                            )
                                : Container(),

                            // Icon Wow
                            whichIconUserChoose == 4 && !isDragging
                                ? Container(
                              child: Transform.scale(
                                child: Image.asset(
                                  'images/wow.gif',
                                  width: 40.0,
                                  height: 40.0,
                                ),
                                scale: this.zoomIconWhenRelease.value,
                              ),
                              margin: EdgeInsets.only(
                                top: processTopPosition(this.moveUpIconWhenRelease.value),
                                left: this.moveLeftIconWowWhenRelease.value,
                              ),
                            )
                                : Container(),

                            // Icon sad
                            whichIconUserChoose == 5 && !isDragging
                                ? Container(
                              child: Transform.scale(
                                child: Image.asset(
                                  'images/sad.gif',
                                  width: 40.0,
                                  height: 40.0,
                                ),
                                scale: this.zoomIconWhenRelease.value,
                              ),
                              margin: EdgeInsets.only(
                                top: processTopPosition(this.moveUpIconWhenRelease.value),
                                left: this.moveLeftIconSadWhenRelease.value,
                              ),
                            )
                                : Container(),

                            // Icon angry
                            whichIconUserChoose == 6 && !isDragging
                                ? Container(
                              child: Transform.scale(
                                child: Image.asset(
                                  'images/angry.gif',
                                  width: 40.0,
                                  height: 40.0,
                                ),
                                scale: this.zoomIconWhenRelease.value,
                              ),
                              margin: EdgeInsets.only(
                                top: processTopPosition(this.moveUpIconWhenRelease.value),
                                left: this.moveLeftIconAngryWhenRelease.value,
                              ),
                            )
                                : Container(),
                          ],
                        ),
                        margin: EdgeInsets.only(left: 5.0, right: 20.0),
                        alignment: Alignment.bottomCenter,
                        // Area of the content can drag
                        // decoration:  BoxDecoration(border: Border.all(color: Colors.grey)),
                        width: double.infinity,
                        height: 500.0,
                      ),

                    ],
                  ),
                  onHorizontalDragEnd: onHorizontalDragEndBoxIcon,
                  onHorizontalDragUpdate: onHorizontalDragUpdateBoxIcon,
                ),
              ],
            ),


    );
  }

  Widget _buildChessBoard() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: ChessBoard(
        size: MediaQuery.of(context).size.width,

        onMove: (moveNotation) {
          gameMoves.add(moveNotation);
          print("user");
          bool aa = !turn;
          setState(() {
            turn = aa;
            print(turn);
          });
          print(api_board.last_move);
          channel.sink.add("m,${api_board.last_move}");
        },
        onCheckMate: (winColor) {
          _showDialog(winColor: winColor);
        },

        onDraw: () {
          _showDialog();
        },
        chessBoardController: controller,
        enableUserMoves: true,
        whiteSideTowardsUser:widget.me_or_he,


        //   whiteSideTowardsUser:flipBoardOnMove ? gameMoves.length % 2 == 0 ? true : false : true,
      ),
    );
  }

  Widget _buildNotationAndOptions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Flip board on move",
                style: TextStyle(fontSize: 18.0),
              ),
              Switch(
                  value: flipBoardOnMove,
                  onChanged: (value) {
                    flipBoardOnMove = value;
                    setState(() {});
                  }),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      _resetGame();
                    },
                    child: Text("Reset game"),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      _undoMove();
                    },
                    child: Text("Undo Move"),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: _buildMovesList(),
          )
        ],
      ),
    );
  }

  void _showDialog({String winColor}) {
    winColor != null
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("Checkmate!"),
                content: new Text("$winColor wins!"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("Play Again"),
                    onPressed: () {
                      _resetGame();
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          )
        : showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("Draw!"),
                content: new Text("The game is a draw!"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("Play Again"),
                    onPressed: () {
                      _resetGame();
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
  }

  void _resetGame() {
    controller.resetBoard();
    gameMoves.clear();
    setState(() {});
  }

  void _undoMove() {
    controller.game.undo_move();
    if (gameMoves.length != 0) gameMoves.removeLast();
    setState(() {});
  }

  List<Widget> _buildMovesList() {
    List<Widget> children = [];

    for (int i = 0; i < gameMoves.length; i++) {
      if (i % 2 == 0) {
        children.add(Text(
            "${(i / 2 + 1).toInt()}. ${gameMoves[i]} ${gameMoves.length > (i + 1) ? gameMoves[i + 1] : ""}"));
      } else {}
    }

    return children;
  }

  buildList() {
    final List<Widget> list = [
      Text(
        'SPEED:',
        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
      )
    ];

    timeDelays.asMap().forEach((index, delay) {
      list.add(Container(
        child: GestureDetector(
          onTap: () => onSpeedSettingPress(index),
          child: Container(
            child:
                Text(delay.toString(), style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: index == selectedIndex
                  ? Color(0xff3b5998)
                  : Color(0xffDAA520),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
        margin: EdgeInsets.all(5.0),
      ));
    });

    return list;
  }

  initAnimationBtnLike() {
    // long press
    animControlBtnLongPress = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationBtnLongPress));
    zoomIconLikeInBtn =
        Tween(begin: 1.0, end: 0.85).animate(animControlBtnLongPress);
    tiltIconLikeInBtn =
        Tween(begin: 0.0, end: 0.2).animate(animControlBtnLongPress);
    zoomTextLikeInBtn =
        Tween(begin: 1.0, end: 0.85).animate(animControlBtnLongPress);

    zoomIconLikeInBtn.addListener(() {
      setState(() {});
    });
    tiltIconLikeInBtn.addListener(() {
      setState(() {});
    });
    zoomTextLikeInBtn.addListener(() {
      setState(() {});
    });

    // short press
    animControlBtnShortPress = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationBtnShortPress));
    zoomIconLikeInBtn2 =
        Tween(begin: 1.0, end: 0.2).animate(animControlBtnShortPress);
    tiltIconLikeInBtn2 =
        Tween(begin: 0.0, end: 0.8).animate(animControlBtnShortPress);

    zoomIconLikeInBtn2.addListener(() {
      setState(() {});
    });
    tiltIconLikeInBtn2.addListener(() {
      setState(() {});
    });
  }

  initAnimationBoxAndIcons() {
    animControlBox = AnimationController(
        vsync: this, duration: Duration(milliseconds: durationAnimationBox));

    // General
    moveRightGroupIcon = Tween(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.0, 1.0)),
    );
    moveRightGroupIcon.addListener(() {
      setState(() {});
    });

    // Box
    fadeInBox = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.7, 1.0)),
    );
    fadeInBox.addListener(() {
      setState(() {});
    });

    // Icons
    pushIconLikeUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.0, 0.5)),
    );
    zoomIconLike = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.0, 0.5)),
    );

    pushIconLoveUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.1, 0.6)),
    );
    zoomIconLove = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.1, 0.6)),
    );

    pushIconHahaUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.2, 0.7)),
    );
    zoomIconHaha = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.2, 0.7)),
    );

    pushIconWowUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.3, 0.8)),
    );
    zoomIconWow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.3, 0.8)),
    );

    pushIconSadUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.4, 0.9)),
    );
    zoomIconSad = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.4, 0.9)),
    );

    pushIconAngryUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.5, 1.0)),
    );
    zoomIconAngry = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.5, 1.0)),
    );

    pushIconLikeUp.addListener(() {
      setState(() {});
    });
    zoomIconLike.addListener(() {
      setState(() {});
    });
    pushIconLoveUp.addListener(() {
      setState(() {});
    });
    zoomIconLove.addListener(() {
      setState(() {});
    });
    pushIconHahaUp.addListener(() {
      setState(() {});
    });
    zoomIconHaha.addListener(() {
      setState(() {});
    });
    pushIconWowUp.addListener(() {
      setState(() {});
    });
    zoomIconWow.addListener(() {
      setState(() {});
    });
    pushIconSadUp.addListener(() {
      setState(() {});
    });
    zoomIconSad.addListener(() {
      setState(() {});
    });
    pushIconAngryUp.addListener(() {
      setState(() {});
    });
    zoomIconAngry.addListener(() {
      setState(() {});
    });
  }

  initAnimationIconWhenDrag() {
    animControlIconWhenDrag = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationIconWhenDrag));

    zoomIconChosen =
        Tween(begin: 1.0, end: 1.8).animate(animControlIconWhenDrag);
    zoomIconNotChosen =
        Tween(begin: 1.0, end: 0.8).animate(animControlIconWhenDrag);
    zoomBoxIcon =
        Tween(begin: 50.0, end: 40.0).animate(animControlIconWhenDrag);

    zoomIconChosen.addListener(() {
      setState(() {});
    });
    zoomIconNotChosen.addListener(() {
      setState(() {});
    });
    zoomBoxIcon.addListener(() {
      setState(() {});
    });
  }

  initAnimationIconWhenDragOutside() {
    animControlIconWhenDragOutside = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationIconWhenDrag));
    zoomIconWhenDragOutside =
        Tween(begin: 0.8, end: 1.0).animate(animControlIconWhenDragOutside);
    zoomIconWhenDragOutside.addListener(() {
      setState(() {});
    });
  }

  initAnimationBoxWhenDragOutside() {
    animControlBoxWhenDragOutside = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationIconWhenDrag));
    zoomBoxWhenDragOutside =
        Tween(begin: 40.0, end: 50.0).animate(animControlBoxWhenDragOutside);
    zoomBoxWhenDragOutside.addListener(() {
      setState(() {});
    });
  }

  initAnimationIconWhenDragInside() {
    animControlIconWhenDragInside = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationIconWhenDrag));
    zoomIconWhenDragInside =
        Tween(begin: 1.0, end: 0.8).animate(animControlIconWhenDragInside);
    zoomIconWhenDragInside.addListener(() {
      setState(() {});
    });
    animControlIconWhenDragInside.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isJustDragInside = false;
      }
    });
  }

  initAnimationIconWhenRelease() {
    animControlIconWhenRelease = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationIconWhenRelease));

    zoomIconWhenRelease = Tween(begin: 1.8, end: 0.0).animate(CurvedAnimation(
        parent: animControlIconWhenRelease, curve: Curves.decelerate));

    moveUpIconWhenRelease = Tween(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));

    moveLeftIconLikeWhenRelease = Tween(begin: 20.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
    moveLeftIconLoveWhenRelease = Tween(begin: 68.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
    moveLeftIconHahaWhenRelease = Tween(begin: 116.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
    moveLeftIconWowWhenRelease = Tween(begin: 164.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
    moveLeftIconSadWhenRelease = Tween(begin: 212.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
    moveLeftIconAngryWhenRelease = Tween(begin: 260.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));

    zoomIconWhenRelease.addListener(() {
      setState(() {});
    });
    moveUpIconWhenRelease.addListener(() {
      setState(() {});
    });

    moveLeftIconLikeWhenRelease.addListener(() {
      setState(() {});
    });
    moveLeftIconLoveWhenRelease.addListener(() {
      setState(() {});
    });
    moveLeftIconHahaWhenRelease.addListener(() {
      setState(() {});
    });
    moveLeftIconWowWhenRelease.addListener(() {
      setState(() {});
    });
    moveLeftIconSadWhenRelease.addListener(() {
      setState(() {});
    });
    moveLeftIconAngryWhenRelease.addListener(() {
      setState(() {});
    });
  }

  Widget renderBox() {
    return Opacity(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: Colors.grey[300], width: 0.3),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
                // LTRB
                offset: Offset.lerp(Offset(0.0, 0.0), Offset(0.0, 0.5), 10.0)),
          ],
        ),
        width: 300.0,
        height: isDragging
            ? (previousIconFocus == 0 ? this.zoomBoxIcon.value : 40.0)
            : isDraggingOutside ? this.zoomBoxWhenDragOutside.value : 50.0,
        margin: EdgeInsets.only(bottom: 130.0, left: 10.0),
      ),
      opacity: this.fadeInBox.value,
    );
  }

  Widget renderIcons() {
    return Container(
      child: Row(
        children: <Widget>[
          // icon like
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 1
                      ? Container(
                    child: Text(
                      'Like',
                      style: TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0), color: Colors.black.withOpacity(0.3)),
                    padding: EdgeInsets.only(left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'images/like.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconLikeUp.value),
              width: 40.0,
              height: currentIconFocus == 1 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 1
                ? this.zoomIconChosen.value
                : (previousIconFocus == 1
                ? this.zoomIconNotChosen.value
                : isJustDragInside ? this.zoomIconWhenDragInside.value : 0.8))
                : isDraggingOutside ? this.zoomIconWhenDragOutside.value : this.zoomIconLike.value,
          ),

          // icon love
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 2
                      ? Container(
                    child: Text(
                      'Love',
                      style: TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0), color: Colors.black.withOpacity(0.3)),
                    padding: EdgeInsets.only(left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'images/love.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconLoveUp.value),
              width: 40.0,
              height: currentIconFocus == 2 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 2
                ? this.zoomIconChosen.value
                : (previousIconFocus == 2
                ? this.zoomIconNotChosen.value
                : isJustDragInside ? this.zoomIconWhenDragInside.value : 0.8))
                : isDraggingOutside ? this.zoomIconWhenDragOutside.value : this.zoomIconLove.value,
          ),

          // icon haha
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 3
                      ? Container(
                    child: Text(
                      'Haha',
                      style: TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0), color: Colors.black.withOpacity(0.3)),
                    padding: EdgeInsets.only(left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'images/haha.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconHahaUp.value),
              width: 40.0,
              height: currentIconFocus == 3 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 3
                ? this.zoomIconChosen.value
                : (previousIconFocus == 3
                ? this.zoomIconNotChosen.value
                : isJustDragInside ? this.zoomIconWhenDragInside.value : 0.8))
                : isDraggingOutside ? this.zoomIconWhenDragOutside.value : this.zoomIconHaha.value,
          ),

          // icon wow
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 4
                      ? Container(
                    child: Text(
                      'Wow',
                      style: TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0), color: Colors.black.withOpacity(0.3)),
                    padding: EdgeInsets.only(left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'images/wow.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconWowUp.value),
              width: 40.0,
              height: currentIconFocus == 4 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 4
                ? this.zoomIconChosen.value
                : (previousIconFocus == 4
                ? this.zoomIconNotChosen.value
                : isJustDragInside ? this.zoomIconWhenDragInside.value : 0.8))
                : isDraggingOutside ? this.zoomIconWhenDragOutside.value : this.zoomIconWow.value,
          ),

          // icon sad
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 5
                      ? Container(
                    child: Text(
                      'Sad',
                      style: TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0), color: Colors.black.withOpacity(0.3)),
                    padding: EdgeInsets.only(left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'images/sad.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconSadUp.value),
              width: 40.0,
              height: currentIconFocus == 5 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 5
                ? this.zoomIconChosen.value
                : (previousIconFocus == 5
                ? this.zoomIconNotChosen.value
                : isJustDragInside ? this.zoomIconWhenDragInside.value : 0.8))
                : isDraggingOutside ? this.zoomIconWhenDragOutside.value : this.zoomIconSad.value,
          ),

          // icon angry
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 6
                      ? Container(
                    child: Text(
                      'Angry',
                      style: TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0), color: Colors.black.withOpacity(0.3)),
                    padding: EdgeInsets.only(left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'images/angry.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconAngryUp.value),
              width: 40.0,
              height: currentIconFocus == 6 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 6
                ? this.zoomIconChosen.value
                : (previousIconFocus == 6
                ? this.zoomIconNotChosen.value
                : isJustDragInside ? this.zoomIconWhenDragInside.value : 0.8))
                : isDraggingOutside ? this.zoomIconWhenDragOutside.value : this.zoomIconAngry.value,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      width: 300.0,
      height: 200.0,
      margin: EdgeInsets.only(left: this.moveRightGroupIcon.value, top: (MediaQuery.of(context).size.height/2)-100),
      // uncomment here to see area of draggable
      // color: Colors.amber.withOpacity(0.5),
    );
  }

  Widget renderBtnLike() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            child: GestureDetector(
              onTapDown: onTapDownBtn,
              onTapUp: onTapUpBtn,
              onTap: onTapBtn,
              child: Container(
                child: Center(
                  child: Row(
                    children: <Widget>[
                      // Icon like
                      ! isDragging && whichIconUserChoose >0 ?Transform.scale(
                        child: Transform.rotate(
                          child: Image.asset(
                            getImageIconBtn(),
                            width: 80.0,
                            height: 80.0,
                            fit: BoxFit.contain,
                            color: getTintColorIconBtn(),
                          ),
                          angle:
                          !isLongPress ? handleOutputRangeTiltIconLike(tiltIconLikeInBtn2.value) : tiltIconLikeInBtn.value,
                        ),
                        scale:
                        !isLongPress ? handleOutputRangeZoomInIconLike(zoomIconLikeInBtn2.value) : zoomIconLikeInBtn.value,
                      )
                     :Container(
                        child: Transform.scale(
                          child: Text(
                            "You",
                            style: TextStyle(
                              color: getColorTextBtn(),
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          scale: !isLongPress
                              ? handleOutputRangeZoomInIconLike(zoomIconLikeInBtn2.value)
                              : zoomTextLikeInBtn.value,
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                ),
          //      padding: EdgeInsets.all(10.0),
                color: Colors.transparent,
              ),
            ),
            width: 100.0,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: Colors.white,
              border: Border.all(color: getColorBorderBtn()),
            ),
            margin: EdgeInsets.only(top: 0.0),
          ),
        ],
      ),
    );
  }

  Widget he_renderBtnLike() {
    return Padding(
      padding: const EdgeInsets.all(8.0),

      child: Column(
        children: [
          Container(
            child: GestureDetector(

              child: Container(
                child: Center(
                  child: Row(
                    children: <Widget>[
                      // Icon like
                      he_img != 0?
                          Image.asset(
                            getImageIconBtn(he_img: he_img),
                            width: 80.0,
                            height: 80.0,

                          )

                          :Container(
                        child: Text(
                            "opponent",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                ),
                //      padding: EdgeInsets.all(10.0),
                color: Colors.transparent,
              ),
            ),
            width: 100.0,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: Colors.white,
              border: Border.all(color: getColorBorderBtn()),
            ),
        //    margin: EdgeInsets.only(top: 0.0),
          ),
        ],
      ),
    );
  }


  String getTextBtn() {
    if (isDragging) {
      return 'Like';
    }
    switch (whichIconUserChoose) {
      case 1:
        return 'Like';
      case 2:
        return 'Love';
      case 3:
        return 'Haha';
      case 4:
        return 'Wow';
      case 5:
        return 'Sad';
      case 6:
        return 'Angry';
      default:
        return 'Like';
    }
  }

  Color getColorTextBtn() {
    if ((!isLongPress && isLiked)) {
      return Color(0xff3b5998);
    } else if (!isDragging) {
      switch (whichIconUserChoose) {
        case 1:
          return Color(0xff3b5998);
        case 2:
          return Color(0xffED5167);
        case 3:
        case 4:
        case 5:
          return Color(0xffFFD96A);
        case 6:
          return Color(0xffF6876B);
        default:
          return Colors.grey;
      }
    } else {
      return Colors.grey;
    }
  }

  String getImageIconBtn({int he_img=0}) {
    if(he_img != 0){
      switch (he_img) {
        case 1:
          return 'images/ic_like_fill.png';
        case 2:
          return 'images/love.gif';
        case 3:
          return 'images/haha.gif';
        case 4:
          return 'images/wow.gif';
        case 5:
          return 'images/sad.gif';
        case 6:
          return 'images/angry.gif';
        default:
          return 'images/like.gif';
      }
    }
    if (!isLongPress && isLiked) {
      return 'images/ic_like_fill.png';
    } else if (!isDragging) {
      switch (whichIconUserChoose) {
        case 1:
          return 'images/ic_like_fill.png';
        case 2:
          return 'images/love.gif';
        case 3:
          return 'images/haha.gif';
        case 4:
          return 'images/wow.gif';
        case 5:
          return 'images/sad.gif';
        case 6:
          return 'images/angry.gif';
        default:
          return 'images/like.gif';
      }
    } else {
      return 'images/ic_like.png';
    }
  }

  Color getTintColorIconBtn() {
    if (!isLongPress && isLiked) {
      return Color(0xff3b5998);
    } else if (!isDragging && whichIconUserChoose != 0) {
      return null;
    } else {
      return Colors.grey;
    }
  }

  double processTopPosition(double value) {
    // margin top 100 -> 40 -> 160 (value from 180 -> 0)
    if (value >= 120.0) {
      return value - 80.0;
    } else {
      return 160.0 - value;
    }
  }

  Color getColorBorderBtn() {
    if ((!isLongPress && isLiked)) {
      return Color(0xff3b5998);
    } else if (!isDragging) {
      switch (whichIconUserChoose) {
        case 1:
          return Color(0xff3b5998);
        case 2:
          return Color(0xffED5167);
        case 3:
        case 4:
        case 5:
          return Color(0xffFFD96A);
        case 6:
          return Color(0xffF6876B);
        default:
          return Colors.grey;
      }
    } else {
      return Colors.grey[400];
    }
  }

  void onHorizontalDragEndBoxIcon(DragEndDetails dragEndDetail) {
    isDragging = false;
    isDraggingOutside = false;
    isJustDragInside = true;
    previousIconFocus = 0;
    currentIconFocus = 0;

    onTapUpBtn(null);
  }

  void onHorizontalDragUpdateBoxIcon(DragUpdateDetails dragUpdateDetail) {
    // return if the drag is drag without press button
    if (!isLongPress) return;

    // the margin top the box is 150
    // and plus the height of toolbar and the status bar
    // so the range we check is about 200 -> 500

    if (dragUpdateDetail.globalPosition.dy >= 200 &&
        dragUpdateDetail.globalPosition.dy <= 500) {
      isDragging = true;
      isDraggingOutside = false;

      if (isJustDragInside && !animControlIconWhenDragInside.isAnimating) {
        animControlIconWhenDragInside.reset();
        animControlIconWhenDragInside.forward();
      }

      if (dragUpdateDetail.globalPosition.dx >= 20 &&
          dragUpdateDetail.globalPosition.dx < 83) {
        if (currentIconFocus != 1) {
          handleWhenDragBetweenIcon(1);
        }
      } else if (dragUpdateDetail.globalPosition.dx >= 83 &&
          dragUpdateDetail.globalPosition.dx < 126) {
        if (currentIconFocus != 2) {
          handleWhenDragBetweenIcon(2);
        }
      } else if (dragUpdateDetail.globalPosition.dx >= 126 &&
          dragUpdateDetail.globalPosition.dx < 180) {
        if (currentIconFocus != 3) {
          handleWhenDragBetweenIcon(3);
        }
      } else if (dragUpdateDetail.globalPosition.dx >= 180 &&
          dragUpdateDetail.globalPosition.dx < 233) {
        if (currentIconFocus != 4) {
          handleWhenDragBetweenIcon(4);
        }
      } else if (dragUpdateDetail.globalPosition.dx >= 233 &&
          dragUpdateDetail.globalPosition.dx < 286) {
        if (currentIconFocus != 5) {
          handleWhenDragBetweenIcon(5);
        }
      } else if (dragUpdateDetail.globalPosition.dx >= 286 &&
          dragUpdateDetail.globalPosition.dx < 340) {
        if (currentIconFocus != 6) {
          handleWhenDragBetweenIcon(6);
        }
      }
    } else {
      whichIconUserChoose = 0;
      previousIconFocus = 0;
      currentIconFocus = 0;
      isJustDragInside = true;

      if (isDragging && !isDraggingOutside) {
        isDragging = false;
        isDraggingOutside = true;
        animControlIconWhenDragOutside.reset();
        animControlIconWhenDragOutside.forward();
        animControlBoxWhenDragOutside.reset();
        animControlBoxWhenDragOutside.forward();
      }
    }
  }

  void handleWhenDragBetweenIcon(int currentIcon) {
    whichIconUserChoose = currentIcon;
    previousIconFocus = currentIconFocus;
    currentIconFocus = currentIcon;
    animControlIconWhenDrag.reset();
    animControlIconWhenDrag.forward();
  }

  void onTapDownBtn(TapDownDetails tapDownDetail) {
    holdTimer = Timer(durationLongPress, showBox);
  }

  void onTapUpBtn(TapUpDetails tapUpDetail) {
    Timer(Duration(milliseconds: durationAnimationBox), () {
      isLongPress = false;
    });

    holdTimer.cancel();

    animControlBtnLongPress.reverse();

    setReverseValue();
    animControlBox.reverse();

    animControlIconWhenRelease.reset();
    animControlIconWhenRelease.forward();
    if(whichIconUserChoose !=0 && !isDragging){
      channel.sink.add("e$whichIconUserChoose");
      print("s$whichIconUserChoose");
    }else{
      channel.sink.add("e0");
    }
  }

  // when user short press the button
  void onTapBtn() {
    if (!isLongPress) {
      if (whichIconUserChoose == 0) {
        isLiked = !isLiked;
      } else {
        whichIconUserChoose = 0;
      }
      if (isLiked) {
        animControlBtnShortPress.forward();
      } else {
        animControlBtnShortPress.reverse();
      }
    }
  }

  double handleOutputRangeZoomInIconLike(double value) {
    if (value >= 0.8) {
      return value;
    } else if (value >= 0.4) {
      return 1.6 - value;
    } else {
      return 0.8 + value;
    }
  }

  double handleOutputRangeTiltIconLike(double value) {
    if (value <= 0.2) {
      return value;
    } else if (value <= 0.6) {
      return 0.4 - value;
    } else {
      return -(0.8 - value);
    }
  }

  void showBox() {
    isLongPress = true;

    animControlBtnLongPress.forward();

    setForwardValue();
    animControlBox.forward();
  }

  // We need to set the value for reverse because if not
  // the angry-icon will be pulled down first, not the like-icon
  void setReverseValue() {
    // Icons
    pushIconLikeUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.5, 1.0)),
    );
    zoomIconLike = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.5, 1.0)),
    );

    pushIconLoveUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.4, 0.9)),
    );
    zoomIconLove = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.4, 0.9)),
    );

    pushIconHahaUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.3, 0.8)),
    );
    zoomIconHaha = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.3, 0.8)),
    );

    pushIconWowUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.2, 0.7)),
    );
    zoomIconWow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.2, 0.7)),
    );

    pushIconSadUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.1, 0.6)),
    );
    zoomIconSad = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.1, 0.6)),
    );

    pushIconAngryUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.0, 0.5)),
    );
    zoomIconAngry = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.0, 0.5)),
    );
  }

  // When set the reverse value, we need set value to normal for the forward
  void setForwardValue() {
    // Icons
    pushIconLikeUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.0, 0.5)),
    );
    zoomIconLike = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.0, 0.5)),
    );

    pushIconLoveUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.1, 0.6)),
    );
    zoomIconLove = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.1, 0.6)),
    );

    pushIconHahaUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.2, 0.7)),
    );
    zoomIconHaha = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.2, 0.7)),
    );

    pushIconWowUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.3, 0.8)),
    );
    zoomIconWow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.3, 0.8)),
    );

    pushIconSadUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.4, 0.9)),
    );
    zoomIconSad = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.4, 0.9)),
    );

    pushIconAngryUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.5, 1.0)),
    );
    zoomIconAngry = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.5, 1.0)),
    );
  }


}
