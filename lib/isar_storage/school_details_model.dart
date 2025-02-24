import 'package:isar/isar.dart';

part 'school_details_model.g.dart';

@Collection()
class SchoolDetails {
  Id id = Isar.autoIncrement;

  late String schoolName;
  late String schoolType;
  late String schoolLocation;
  late String schoolContact;
  late String schoolWebsite;
  String? schoolImageUrl;
}
