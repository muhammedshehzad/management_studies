import 'package:isar/isar.dart';

part 'academic_records_model.g.dart';
@Collection()
class StudentDetailModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;

  late String name;
  late String email;
  late double score;
  late double percentage;
  late String grade;
  late String status;
  late String academicYear;
  late String registerNumber;
  late String admissionNumber;
  late DateTime admissionDate;
  late String department;
  late String hod;
  late String fatherName;
  late String fatherOccupation;
  late String fatherPhone;
  late String motherName;
  late String motherOccupation;
  late String motherPhone;
}

