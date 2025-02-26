import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class LeavesBloc {
  final _leavesController = BehaviorSubject<QuerySnapshot>();

  LeavesBloc() {
    fetchStudentLeaves().listen(_leavesController.add);
  }

  Stream<QuerySnapshot> get leavesStream => _leavesController.stream;

  void dispose() {
    _leavesController.close();
  }

  Stream<QuerySnapshot> fetchStudentLeaves() async* {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final userDocSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser?.uid)
        .get();

    if (!userDocSnapshot.exists ||
        userDocSnapshot.data()?['department'] == null) {
      yield* Stream.empty();
      return;
    }

    final userDepartment = userDocSnapshot.data()!['department'];
    yield* FirebaseFirestore.instance
        .collection('Leaves')
        .where("creator_role", isEqualTo: "student")
        .where("userDepartment", isEqualTo: userDepartment)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
