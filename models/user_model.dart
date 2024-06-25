class UserModel {
  String? dateOfBirth;
  String? email;
  String? name;
  String? gender;
  String? phoneNumber;
  String? role;
  String? uid;

  UserModel({
    this.dateOfBirth,
    this.email,
    this.name,
    this.gender,
    this.phoneNumber,
    this.role,
    this.uid,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    dateOfBirth = json['date of Birth'];
    email = json['email'];
    name = json['full Name'];
    gender = json['male'];
    phoneNumber = json['phoneNumber'];
    role = json['role'];
    uid = json['uid'];
  }
}
