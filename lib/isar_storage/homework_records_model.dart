import 'package:isar/isar.dart';

part 'homework_records_model.g.dart';

@Collection()
class HomeworkRecordModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String docid; // Unique document ID

  late String subject;
  late String title;
  late DateTime deadline;
  late String status;
  late String assignedBy;
  late String description;
  late String estimatedTime;
}
