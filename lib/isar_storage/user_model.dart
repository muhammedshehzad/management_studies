import 'package:isar/isar.dart';

part 'user_model.g.dart';

@Collection()
class UserModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String uid;
  late String username;
  late String email;
  late String phone;
  late String address;
  late String role;
  late String department;
  late String url;
}
