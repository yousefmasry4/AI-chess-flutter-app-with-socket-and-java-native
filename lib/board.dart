
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:untitled8/board_data.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
class board extends StatefulWidget {
  @override
  _PlayGamePageState createState() => _PlayGamePageState();
}

class _PlayGamePageState extends State<board> {
  ChessBoardController controller;
  List<String> gameMoves = [];
  var flipBoardOnMove = true;
  final WebSocketChannel channel = IOWebSocketChannel.connect(
    Uri(scheme: "ws", host: "192.168.43.101", port: 8080, path: "/socket"),
  );
  bool turn=true;

  @override
  void initState() {
    super.initState();
    channel.sink.add("go");
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller = ChessBoardController();
    channel.stream.listen((event) {
      print(event);
      var x=event.split(",");
      print("jjjjjjjjjj");
      print(x[0].toString().split("")[1]);
      if(event.toString().length == 5) {
   //     x[0]=x[0][0]+(9-int.parse(x[0].toString().split("")[1])).toString();
      //  x[1]=x[1][0]+(9-int.parse(x[1].toString().split("")[1])).toString();
        print(x[0]);
        controller.makeMove(x[0], x[1]);
        bool aa=!turn;
        setState(() {
          turn=aa;
          print("from server $event");
          print("and $x");
          print(turn);

        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    channel.sink.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Play with a friend"),

      ),
      body: ListView(
          children: <Widget>[
      Stack(
        children: [
          _buildChessBoard(),
          Visibility(
            visible: !turn,
            child:Container(
              width:  MediaQuery.of(context).size.width,
              height:  MediaQuery.of(context).size.width,
              color: Colors.transparent,

            ),
          )
        ],
      ),
      //      _buildNotationAndOptions(),
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
          bool aa=!turn;
          setState(() {
            turn=aa;
            print(turn);

          });
          print(api_board.last_move);
          channel.sink.add(api_board.last_move);

        },
        onCheckMate: (winColor) {
          _showDialog(winColor: winColor);
        },
        onDraw: () {
          _showDialog();
        },
        chessBoardController: controller,
        enableUserMoves: true,
        whiteSideTowardsUser: true,
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
    if(gameMoves.length != 0)
      gameMoves.removeLast();
    setState(() {
    });
  }

  List<Widget> _buildMovesList() {
    List<Widget> children = [];

    for(int i = 0; i < gameMoves.length; i++) {
      if(i%2 == 0) {
        children.add(Text("${(i/2+ 1).toInt()}. ${gameMoves[i]} ${gameMoves.length > (i+1) ? gameMoves[i+1] : ""}"));
      }else {

      }
    }

    return children;

  }

}
