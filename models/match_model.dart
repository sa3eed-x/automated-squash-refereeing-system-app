class Match {
  String? uid;
  String? player1;
  String? player2;
  String? courtNumber;
  String? dateTime;
  List<String>? referee;
  Match(
      {this.uid, this.player1, this.player2, this.courtNumber, this.dateTime});

  Match.fromJson(Map<String, dynamic> json) {
    player1 = json['player1'];
    player2 = json['player2'];
    courtNumber = json['courtNumber'];
    dateTime = json['dateTime'];
    referee =
        (json['referee'] as List<dynamic>).map((e) => e as String).toList();
    uid = json['uid'];
  }
}
