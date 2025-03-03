import 'package:isar/isar.dart';

part 'leave_request_model.g.dart';

@Collection()
class LeaveRequest {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  @Index()
  late String leavesId;

  bool pendingSync = false;
  late String username;
  late String userDepartment;
  late String creatorRole;
  late String leaveType;
  late DateTime startDate;
  late DateTime endDate;
  late DateTime createdAt;
  late String leaveReason;
  late int durationDays;
  late String status;
  late bool isSynced;
  bool notificationSent = false;
}
