import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:isar/isar.dart';
import 'package:new_school/isar_storage/leave_request_model.dart';
import 'package:new_school/isar_storage/isar_user_service.dart';
import '../../notifications/notification_services.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();

  factory SyncManager() => _instance;

  SyncManager._internal();

  bool _isSyncing = false;
  StreamSubscription? _connectivitySubscription;

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void init() {
    _startConnectivitySubscription();
    syncUnsyncedLeaves();
  }

  void _startConnectivitySubscription() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none && await hasInternet()) {
        await syncUnsyncedLeaves();
      }
    });
  }

  Future<void> syncUnsyncedLeaves() async {
    if (_isSyncing || !await hasInternet()) return;
    _isSyncing = true;
    try {
      final unsyncedLeaves = await IsarUserService.isar!.leaveRequests
          .where()
          .filter()
          .isSyncedEqualTo(false)
          .findAll();

      for (final leave in unsyncedLeaves) {
        leave.isSynced = true;
        await IsarUserService.isar!.writeTxn(() async {
          await IsarUserService.isar!.leaveRequests.put(leave);
        });

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

        final docRef =
            FirebaseFirestore.instance.collection('Leaves').doc(leave.leavesId);
        final docSnapshot = await docRef.get();

        try {
          if (docSnapshot.exists) {
            if (docSnapshot.data()!['status'] != leave.status) {
              await docRef.update({'status': leave.status});
            }
          } else {
            await docRef.set(leaveData);
          }

          if (!leave.notificationSent &&
              (!docSnapshot.exists ||
                  docSnapshot.data()!['status'] != leave.status)) {
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

            leave.notificationSent = true;
            await IsarUserService.isar!.writeTxn(() async {
              await IsarUserService.isar!.leaveRequests.put(leave);
            });
          }
        } catch (e) {
          leave.isSynced = false;
          await IsarUserService.isar!.writeTxn(() async {
            await IsarUserService.isar!.leaveRequests.put(leave);
          });
        }
      }
    } catch (e) {
      print("Error syncing leaves: $e");
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
