import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/sign_in_page.dart';
import 'leave_status_provider.dart';

class CustomStatusButton extends StatefulWidget {
  final String initialStatus;
  final String leaveId;
  final bool closesheet;

  const CustomStatusButton({
    Key? key,
    required this.initialStatus,
    required this.leaveId,
    this.closesheet = false,
  }) : super(key: key);

  @override
  _CustomStatusButtonState createState() => _CustomStatusButtonState();
}

class _CustomStatusButtonState extends State<CustomStatusButton> {
  bool isOnline = false;
  StreamSubscription? _connectivitySubscription;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _wasOffline = true;
    _checkInternet();
    final provider = Provider.of<LeaveStatusProvider>(context, listen: false);
    provider.getStatus(widget.leaveId, widget.initialStatus);
    provider.syncUnsyncedLeaves(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      bool newOnlineStatus =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      setState(() {
        isOnline = newOnlineStatus;
      });

      if (_wasOffline && newOnlineStatus) {
        debugPrint('Connectivity restored, triggering sync of unsynced leaves');
        final provider =
            Provider.of<LeaveStatusProvider>(context, listen: false);
        await provider.syncUnsyncedLeaves(context);
      }

      _wasOffline = !newOnlineStatus;

      _connectivitySubscription?.cancel();
      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen((results) {
        final ConnectivityResult result =
            results.isNotEmpty ? results.first : ConnectivityResult.none;
        _handleConnectivityChange(result);
      });
    } catch (e) {
      setState(() {
        isOnline = false;
        _wasOffline = true;
      });
    }
  }

  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    try {
      bool newOnlineStatus = false;
      if (result != ConnectivityResult.none) {
        final lookupResult = await InternetAddress.lookup('google.com');
        newOnlineStatus =
            lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;
      }

      bool statusChanged = newOnlineStatus != isOnline;

      if (statusChanged) {
        setState(() {
          isOnline = newOnlineStatus;
        });

        if (newOnlineStatus && _wasOffline) {
          debugPrint(
              'Connectivity changed to online after being offline, syncing leaves');
          final provider =
              Provider.of<LeaveStatusProvider>(context, listen: false);
          await provider.syncUnsyncedLeaves(context);
          await syncLeavesFirestoreToIsar();
          await provider.loadLeaveStatus(widget.leaveId);
          await provider.refreshLeaveStatuses();
        }

        _wasOffline = !newOnlineStatus;
      }
    } catch (e) {
      debugPrint("Error handling connectivity change: $e");
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveStatusProvider>(
      builder: (context, provider, child) {
        final status = provider.getStatus(widget.leaveId, widget.initialStatus);
        final showButtons = provider.shouldShowButtons(widget.leaveId);
        final showOfflineIndicator = !isOnline && status == 'Pending';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Status: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: status == 'Approved'
                            ? Colors.green
                            : status == 'Rejected'
                                ? Colors.red
                                : Colors.orange,
                      ),
                    )
                  ],
                ),
                if (showOfflineIndicator)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Text(
                          'offline ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Icon(
                          Icons.cloud_off,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (showButtons)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildButton(
                      text: 'Approve',
                      color: Colors.green,
                      onTap: () => _updateStatus(context, 'Approved'),
                    ),
                    _buildButton(
                      text: 'Reject',
                      color: Colors.red,
                      onTap: () => _updateStatus(context, 'Rejected'),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    final provider = Provider.of<LeaveStatusProvider>(context, listen: false);
    final success =
        await provider.updateLeaveStatus(widget.leaveId, newStatus, context);

    if (success && widget.closesheet && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0.5,
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
