class UserModel {
  final String id;
  final String phone;

  UserModel({required this.id, required this.phone});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'] as String, phone: json['phone'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'phone': phone};
}
