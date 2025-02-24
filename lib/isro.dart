// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:isar/isar.dart';
//
// class Bankdetails extends StatefulWidget {
//   const Bankdetails({super.key});
//
//   @override
//   State<Bankdetails> createState() => _BankdetailsState();
// }
//
// TextEditingController us = TextEditingController();
// TextEditingController tp = TextEditingController();
// TextEditingController hq = TextEditingController();
// TextEditingController cn = TextEditingController();
// TextEditingController wb = TextEditingController();
//
// bool enable = false;
//
// class _BankdetailsState extends State<Bankdetails> {
//   CollectionReference userref = FirebaseFirestore.instance.collection('bank');
//
//   Future<void> updateProfile(BuildContext context) async {
//     final bankDetails = BankDetails()
//       ..name = us.text
//       ..type = tp.text
//       ..headquarters = hq.text
//       ..contact = cn.text
//       ..website = wb.text;
//     try {
//       await userref.doc('details').update({
//         'name': us.text,
//         'type': tp.text,
//         'headquarters': hq.text,
//         'contact': cn.text,
//         'website': wb.text,
//       });
//       await isar.writeTxn(() async {
//         await isar.bankDetails.put(bankDetails);
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Profile Updated')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Profile not updated')),
//       );
//     }
//   }
//
//   Future<void> loadBankDetailsFromIsar() async {
//     final cachedBankDetails = await isar.bankDetails.get(1);
//
//     if (cachedBankDetails != null) {
//       setState(() {
//         us.text = cachedBankDetails.name;
//
//         tp.text = cachedBankDetails.type;
//
//         hq.text = cachedBankDetails.headquarters;
//
//         cn.text = cachedBankDetails.contact;
//
//         wb.text = cachedBankDetails.website;
//       });
//     }
//   }
//
//   String? role;
//
//   final FirebaseAuth auth = FirebaseAuth.instance;
//
//   void ard() {
//     final User? user = auth.currentUser;
//     final uid = user!.uid;
//
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .get()
//         .then((DocumentSnapshot documentsnapshot) {
//       if (documentsnapshot.exists) {
//         print('Data');
//         final data = documentsnapshot.data() as Map<String, dynamic>?;
//         if (mounted) {
//           setState(() {
//             print(data);
//             role = data!['role'];
//           });
//         }
//       } else {
//         print('no data');
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     ard();
//     print('roles$role');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     late Stream<DocumentSnapshot<Map<String, dynamic>>>? profiledata =
//         FirebaseFirestore.instance
//             .collection('bank')
//             .doc('details')
//             .snapshots();
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         actions: [
//           SizedBox(
//             width: 10,
//           ),
//           role == 'manager'
//               ? IconButton(
//                   onPressed: () {
//                     setState(() {
//                       enable = !enable;
//                     });
//                   },
//                   icon: Icon(!enable ? Icons.edit : Icons.close),
//                 )
//               : SizedBox(),
//         ],
//         backgroundColor: Colors.orange,
//         title: Text('Bank Details'),
//       ),
//       body: StreamBuilder(
//           stream: profiledata,
//           builder: (context, usersnapshot) {
//             final data = usersnapshot.data;
//             if (usersnapshot.hasData) {
//               us.text = data!['name'];
//               tp.text = data!['type'];
//               hq.text = data!['headquarters'];
//               cn.text = data!['contact'];
//               wb.text = data!['website'];
//
//               final bankDetails = BankDetails()
//                 ..name = us.text
//                 ..type = tp.text
//                 ..headquarters = hq.text
//                 ..contact = cn.text
//                 ..website = wb.text;
//               isar.writeTxn(() async {
//                 await isar.bankDetails.put(bankDetails);
//               });
//               return SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: 20,
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 16, vertical: 19),
//                       child: TextField(
//                         enabled: enable,
//                         controller: us,
//                         decoration: InputDecoration(
//                           labelText: 'Bank name',
//                           prefixIcon: Icon(Icons.people_alt),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 16, vertical: 19),
//                       child: TextField(
//                         enabled: enable,
//                         controller: tp,
//                         decoration: InputDecoration(
//                           labelText: 'Type',
//                           prefixIcon: Icon(Icons.business),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 16, vertical: 19),
//                       child: TextField(
//                         enabled: enable,
//                         controller: hq,
//                         decoration: InputDecoration(
//                           labelText: 'Headquartes',
//                           prefixIcon: Icon(Icons.apartment_outlined),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 16, vertical: 19),
//                       child: TextField(
//                         enabled: enable,
//                         controller: cn,
//                         decoration: InputDecoration(
//                           labelText: 'Contact',
//                           prefixIcon: Icon(Icons.call),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 16, vertical: 19),
//                       child: TextField(
//                         enabled: enable,
//                         controller: wb,
//                         decoration: InputDecoration(
//                           labelText: 'Website',
//                           prefixIcon: Icon(Icons.home),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     enable
//                         ? Container(
//                             margin: EdgeInsets.only(left: 50, right: 50),
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.orange,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   updateProfile(context);
//                                 });
//                               },
//                               child: Center(
//                                 child: Text(
//                                   'Update',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         : SizedBox(),
//                   ],
//                 ),
//               );
//             } else {
//               return Scaffold(body: Center(child: CircularProgressIndicator()));
//             }
//           }),
//     );
//   }
// }
