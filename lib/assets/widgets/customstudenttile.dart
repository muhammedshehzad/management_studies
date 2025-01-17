// import 'package:flutter/material.dart';
//
// class CustomStudentTile extends StatelessWidget {
//   const CustomStudentTile(
//       this.subject, this.title, this.deadline, this.status, this.ontap);
//
//   final String subject;
//   final String title;
//   final String deadline;
//   final String status;
//   final void Function() ontap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: .5,
//       child: ListTile(
//         onTap: ontap,
//         title: Text(subject,
//             style:
//                 TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
//         subtitle: Container(
//           width: MediaQuery.of(context).size.width * 0.7,
//           padding: const EdgeInsets.only(bottom: 4.0),
//           child: Text(
//             '${title}',
//             style: const TextStyle(
//               fontWeight: FontWeight.w500,
//               fontSize: 13,
//               color: Colors.black54,
//             ),
//             overflow: TextOverflow.clip,
//           ),
//         ),
//         trailing: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Deadline: ${deadline}',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//             SizedBox(
//               height: 5,
//             ),
//             Text(
//               status,
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                   color: Colors.black87),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
