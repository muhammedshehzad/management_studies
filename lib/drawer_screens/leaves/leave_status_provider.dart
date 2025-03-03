import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:new_school/isar_storage/leave_request_model.dart';
import '../../notifications/notification_services.dart';
import '../../isar_storage/isar_user_service.dart';

class LeaveStatusProvider extends ChangeNotifier {
  bool _isSyncing = false;
  final Map<String, String> _statusCache = {};
  final Map<String, bool> _showButtonsCache = {};
  final Set<String> _processingSyncLeaves = {};

  String getStatus(String leaveId, String defaultStatus) {
    if (!_statusCache.containsKey(leaveId)) {
      _statusCache[leaveId] = defaultStatus;
      _showButtonsCache[leaveId] = defaultStatus == 'Pending';
      loadLeaveStatus(leaveId);
    }
    return _statusCache[leaveId]!;
  }

  bool shouldShowButtons(String leaveId) {
    return _showButtonsCache[leaveId] ?? false;
  }

  Future<void> refreshLeaveStatuses() async {
    _statusCache.clear();
    _showButtonsCache.clear();
    notifyListeners();

    await syncUnsyncedLeaves(null);
  }

  Future<void> loadLeaveStatus(String leaveId) async {
    if (IsarUserService.isar != null) {
      LeaveRequest? leaveRequest = await IsarUserService.isar!.leaveRequests
          .where()
          .leavesIdEqualTo(leaveId)
          .findFirst();

      if (leaveRequest != null) {
        _statusCache[leaveId] = leaveRequest.status;
        _showButtonsCache[leaveId] = leaveRequest.status == 'Pending';
        notifyListeners();
      }
    }
  }

  Future<bool> updateLeaveStatus(
      String leaveId, String newStatus, BuildContext context) async {
    try {
      bool online = await _hasInternet();

      if (IsarUserService.isar == null) {
        throw Exception("Local database is not initialized");
      }

      LeaveRequest? leaveRequest = await IsarUserService.isar!.leaveRequests
          .where()
          .leavesIdEqualTo(leaveId)
          .findFirst();

      if (leaveRequest == null && online) {
        DocumentSnapshot leaveDoc = await FirebaseFirestore.instance
            .collection('Leaves')
            .doc(leaveId)
            .get();

        if (leaveDoc.exists) {
          final leaveData = leaveDoc.data() as Map<String, dynamic>;
          leaveRequest = LeaveRequest()
            ..userId = leaveData['userId'] ?? ''
            ..leavesId = leaveId
            ..username = leaveData['username'] ?? ''
            ..userDepartment = leaveData['userDepartment'] ?? ''
            ..creatorRole = leaveData['creator_role'] ?? ''
            ..leaveType = leaveData['leaveType'] ?? ''
            ..startDate = (leaveData['startDate'] as Timestamp).toDate()
            ..endDate = (leaveData['endDate'] as Timestamp).toDate()
            ..leaveReason = leaveData['leaveReason'] ?? ''
            ..durationDays = leaveData['durationDays'] ?? 0
            ..status = leaveData['status'] ?? 'Pending'
            ..createdAt = leaveData['createdAt'] != null
                ? (leaveData['createdAt'] as Timestamp).toDate()
                : DateTime.now()
            ..isSynced = true;

          await IsarUserService.isar!.writeTxn(() async {
            await IsarUserService.isar!.leaveRequests.put(leaveRequest!);
          });
        } else {
          throw Exception("Leave request does not exist in Firestore");
        }
      }

      if (leaveRequest == null) {
        throw Exception(
            "Leave request not found locally and device is offline");
      }

      await IsarUserService.isar!.writeTxn(() async {
        leaveRequest!.status = newStatus;
        leaveRequest.isSynced = online;
        leaveRequest.notificationSent = false;
        await IsarUserService.isar!.leaveRequests.put(leaveRequest);
      });

      if (online) {
        await FirebaseFirestore.instance
            .collection('Leaves')
            .doc(leaveId)
            .update({'status': newStatus});

        DocumentSnapshot leaveDoc = await FirebaseFirestore.instance
            .collection('Leaves')
            .doc(leaveId)
            .get();

        if (leaveDoc.exists) {
          final leaveData = leaveDoc.data() as Map<String, dynamic>;
          String requesterId = leaveData['userId'] ?? "Unknown";
          String username = leaveData['username'] ?? "Unknown";
          String role = leaveData['creator_role'] ?? "Unknown";
          String leaveType = leaveData['leaveType'] ?? "Unknown";
          String reason = leaveData['leaveReason'] ?? "No reason provided";
          String startDate = leaveData['startDate'] != null
              ? (leaveData['startDate'] as Timestamp)
                  .toDate()
                  .toLocal()
                  .toString()
                  .split(' ')[0]
              : "Unknown";
          String endDate = leaveData['endDate'] != null
              ? (leaveData['endDate'] as Timestamp)
                  .toDate()
                  .toLocal()
                  .toString()
                  .split(' ')[0]
              : "Unknown";

          final Map<String, dynamic> notificationParams = {
            'userId': requesterId,
            'title': "Leave Status Updated",
            'message':
                "Your leave request for $reason from $startDate to $endDate has been $newStatus.",
            'type': "LeaveStatus",
            'payload': <String, dynamic>{
              "userName": username,
              "userRole": role,
              "leaveType": leaveType,
              "leaveStatus": newStatus,
            },
          };

          await sendNotification(
            userId: notificationParams['userId'] as String,
            title: notificationParams['title'] as String,
            message: notificationParams['message'] as String,
            type: notificationParams['type'] as String,
            payload: notificationParams['payload'] as Map<String, dynamic>,
          );

          await IsarUserService.isar!.writeTxn(() async {
            leaveRequest!.notificationSent = true;
            await IsarUserService.isar!.leaveRequests.put(leaveRequest);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated offline, will upload when online.'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(10),
          ),
        );
      }

      _statusCache[leaveId] = newStatus;
      _showButtonsCache[leaveId] = newStatus == 'Pending';
      notifyListeners();

      await loadLeaveStatus(leaveId);

      return true;
    } catch (e) {
      debugPrint("Error updating leave status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status. Please try again.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(10),
        ),
      );
      return false;
    }
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> syncUnsyncedLeaves(BuildContext? context) async {
    if (_isSyncing) return false;

    bool isOnline = await _hasInternet();
    if (!isOnline) return false;

    _isSyncing = true;
    // debugPrint("Starting to sync unsynced leaves");

    try {
      final unsyncedLeaves = await IsarUserService.isar!.leaveRequests
          .where()
          .filter()
          .isSyncedEqualTo(false)
          .findAll();

      // debugPrint("Found ${unsyncedLeaves.length} unsynced leaves to sync");

      int successfulUploads = 0;

      final leavesToProcess = unsyncedLeaves
          .where((leave) => !_processingSyncLeaves.contains(leave.leavesId))
          .toList();

      // debugPrint(
      //     "Processing ${leavesToProcess.length} leaves (excluding already processing ones)");

      for (final leave in leavesToProcess) {
        _processingSyncLeaves.add(leave.leavesId);
      }

      for (final leave in leavesToProcess) {
        try {
          debugPrint(
              "Syncing leave ${leave.leavesId} with status ${leave.status}");

          final currentLeaveState = await IsarUserService.isar!.leaveRequests
              .where()
              .leavesIdEqualTo(leave.leavesId)
              .findFirst();

          if (currentLeaveState != null && currentLeaveState.isSynced) {
            debugPrint("Leave ${leave.leavesId} is already synced, skipping");
            continue;
          }

          final docRef = FirebaseFirestore.instance
              .collection('Leaves')
              .doc(leave.leavesId);
          final docSnapshot = await docRef.get();

          if (docSnapshot.exists) {
            await docRef.update({'status': leave.status});
            debugPrint("Updated status in Firestore for ${leave.leavesId}");
          } else {
            final leaveData = {
              'userId': leave.userId,
              'username': leave.username,
              'userDepartment': leave.userDepartment,
              'creator_role': leave.creatorRole,
              'leaveType': leave.leaveType,
              'startDate': Timestamp.fromDate(leave.startDate),
              'endDate': Timestamp.fromDate(leave.endDate),
              'leaveReason': leave.leaveReason,
              'createdAt': leave.createdAt != null
                  ? Timestamp.fromDate(leave.createdAt!)
                  : FieldValue.serverTimestamp(),
              'durationDays': leave.durationDays,
              'status': leave.status,
              'leavesid': leave.leavesId,
            };
            await docRef.set(leaveData);
            debugPrint(
                "Created new document in Firestore for ${leave.leavesId}");
          }

          if (!leave.notificationSent) {
            await sendNotification(
              userId: leave.userId,
              title: "Leave Status Updated",
              message:
                  "Your leave request for ${leave.leaveReason} from ${leave.startDate.toLocal().toString().split(' ')[0]} to ${leave.endDate.toLocal().toString().split(' ')[0]} has been ${leave.status}.",
              type: "LeaveStatus",
              payload: {
                "userName": leave.username,
                "userRole": leave.creatorRole,
                "leaveType": leave.leaveType,
                "leaveStatus": leave.status,
              },
            );
            debugPrint("Sent notification for ${leave.leavesId}");
          }

          await IsarUserService.isar!.writeTxn(() async {
            leave.isSynced = true;
            leave.notificationSent = true;
            await IsarUserService.isar!.leaveRequests.put(leave);
          });
          debugPrint("Marked ${leave.leavesId} as synced in local database");

          successfulUploads++;

          if (_statusCache.containsKey(leave.leavesId)) {
            _statusCache[leave.leavesId] = leave.status;
            _showButtonsCache[leave.leavesId] = leave.status == 'Pending';
          }
        } catch (e) {
          debugPrint("Error syncing leave ${leave.leavesId}: $e");
        } finally {
          _processingSyncLeaves.remove(leave.leavesId);
        }
      }

      if (successfulUploads > 0) {
        notifyListeners();
        debugPrint("Successfully synced $successfulUploads leaves");
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$successfulUploads leave data items uploaded.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(10),
            ),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error in syncUnsyncedLeaves: $e");
      return false;
    } finally {
      _isSyncing = false;
    }
  }
}
