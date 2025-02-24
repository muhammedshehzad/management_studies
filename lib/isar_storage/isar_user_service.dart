import 'package:isar/isar.dart';
import 'package:new_school/isar_storage/academic_records_model.dart';
import 'package:new_school/isar_storage/homework_records_model.dart';
import 'package:new_school/isar_storage/leave_request_model.dart';
import 'package:new_school/isar_storage/transaction_model.dart';
import 'package:path_provider/path_provider.dart';
import 'school_details_model.dart';
import 'user_model.dart';

class IsarUserService {
  static Isar? isar;

  static Future<Isar> init() async {
    if (isar != null) {
      return isar!;
    }
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        UserModelSchema,
        SchoolDetailsSchema,
        StudentDetailModelSchema,
        HomeworkRecordModelSchema,
        LeaveRequestSchema,
        TransactionModelSchema,
      ],
      directory: dir.path,
    );
    return isar!;
  }

  static bool get isInitialized => isar != null;
}
