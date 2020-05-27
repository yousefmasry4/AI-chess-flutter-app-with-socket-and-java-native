class api_board{
  static String last_move="";
  static const Map SQUARES = const {
    'a8':  "0,0", 'b8':   "0,1", 'c8':   "0,2", 'd8':   "0,3", 'e8':  "0,4", 'f8':   "0,5", 'g8':   "0,6", 'h8':   "0,7",
    'a7':  "1,0", 'b7':  "1,1", 'c7':  "1,2", 'd7':  "1,3", 'e7':  "1,4", 'f7':  "1,5", 'g7':  "1,6", 'h7':  "1,7",
    'a6':  "2,0", 'b6':   "2,1", 'c6':   "2,2", 'd6':   "2,3", 'e6':   "2,4", 'f6':   "2,5", 'g6':   "2,6", 'h6':   "2,7",
    'a5':  "3,0", 'b5':  "3,1", 'c5':  "3,2", 'd5':  "3,3", 'e5':  "3,4", 'f5':  "3,5", 'g5':  "3,6", 'h5':  "3,7",
    'a4':  "4,0", 'b4':  "4,1", 'c4':  "4,2", 'd4':  "4,3", 'e4':  "4,4", 'f4':  "4,5", 'g4':  "4,6", 'h4':  "4,7",
    'a3':  "5,0", 'b3':  "5,1", 'c3':  "5,2", 'd3':  "5,3", 'e3':  "5,4", 'f3':  "5,5", 'g3':  "5,6", 'h3':  "5,7",
    'a2':  "6,0", 'b2':  "6,1", 'c2':  "6,2", 'd2':  "6,3", 'e2': "6,4", 'f2': "6,5", 'g2': "6,6", 'h2': "6,7",
    'a1': "7,0", 'b1': "7,1", 'c1': "7,2", 'd1': "7,3", 'e1': "7,4", 'f1': "7,5", 'g1': "7,6", 'h1': "7,7"
  };

  static var api_board_ = new List.generate(8, (_) => new List(8));

  static void rerun(){
    int i=0;
    "rnbqkbnr".split("").forEach((e) {
      api_board_[0][i]="b,"+e;
      i++;
    });
    i=0;
    "rnbqkbnr".split("").forEach((e) {
      api_board_[7][i]="w,"+e;
      i++;
    });
    i=0;
    "pppppppp".split("").forEach((e) {
      api_board_[1][i]="b,"+e;
      api_board_[6][i]="w,"+e;
      i++;
    });
  }
  static void move(String from,String to){
    var f=SQUARES[from].toString().split(",");
    var t=SQUARES[to].toString().split(",");
    String temp=api_board_[int.parse(f[0])][int.parse(f[1])];
    api_board_[int.parse(f[0])][int.parse(f[1])]=null;
    api_board_[int.parse(t[0])][int.parse(t[1])]=temp;
    last_move=from+","+to;
  }

}

/*
void main() {
  api_board.rerun();

  api_board.move("a7","a6");
  api_board.api_board_.forEach((e) {
    print(e);
  });

}
*/