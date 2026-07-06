# user_model.dart

* **File Path:** `apps/mobile/lib/features/auth/data/models/user_model.dart`
* **Type:** `DART`

---

```dart
class UserModel {
  final String id;
  final String phone;

  UserModel({required this.id, required this.phone});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'] as String, phone: json['phone'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'phone': phone};
}

```
