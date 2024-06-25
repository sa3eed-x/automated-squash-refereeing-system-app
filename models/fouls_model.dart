class Foul {
  String? uid;
  String? camera1;
  String? camera2;
  String? camera3;
  String? decision;

  Foul(
      {this.uid, this.camera1, this.camera2, this.camera3, this.decision});

  Foul.fromJson(Map<String, dynamic> json) {
    camera1 = json['camera1'];
    camera2 = json['camera2'];
    camera3 = json['camera3'];
    decision = json['decision'];
    uid = json['uid'];
  }
}
