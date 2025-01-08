import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class Appointmentshowpage extends StatefulWidget {
  final Map<String, dynamic> data;
  const Appointmentshowpage({super.key, required this.data});

  @override
  State<Appointmentshowpage> createState() => _MedicalRecordsState();
}

class _MedicalRecordsState extends State<Appointmentshowpage> {
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 300));
  String currentfilter = 'None';
  String? selectedname;
  Query? query;
  TextEditingController searchController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    if (widget.data['roles'] == 'patient') {
      clearQuery();
    } else {
      doctorQuery();
    }

    fetchuserdata();
    super.initState();
  }

  void fetcclearquery(DateTime start, DateTime end) {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .where('patientid',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    });
  }

  void clearQuery() {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('records');
    });
  }

  void doctorQuery() async {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    });
  }

  void fetchuserdata() async {
    final user = await Userdata(uid: uid).getData();

    print(user['name']);
  }

  void searchQuery() {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('appointments')
          .where('patientid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('doctorsname')
          .startAt([searchController.text]).endAt(
          [searchController.text + '\uf8ff']);
    });
  }

  void fectcQuery(String name) {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('appointments')
          .where('patientid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('doctorsname', isEqualTo: selectedname);
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        startDate = args.value.startDate;

        endDate = args.value.endDate ?? args.value.startDate;
        fetcclearquery(startDate, endDate);
        print('${startDate}-${endDate}');
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        actions: [
          if (widget.data['roles'] == 'patient')
            IconButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return SizedBox(
                          height: 500,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Filter By",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Select a filtering method",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      DropdownButton<String>(
                                        value: currentfilter,
                                        items: <String>[
                                          'None',
                                          'Doctors name',
                                          'Date range',
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            currentfilter = value!;
                                            print(currentfilter);
                                          });
                                        },
                                      ),
                                      Spacer(),
                                      ElevatedButton(
                                          onPressed: () {
                                            clearQuery();
                                          },
                                          child: Text("Clear Filter"))
                                    ],
                                  ),
                                  if (currentfilter == 'None') ...[
                                    Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child:
                                        Text('No Filter Category Selected'),
                                      ),
                                    ),
                                  ],
                                  if (currentfilter == 'Date range') ...[
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: SfDateRangePicker(
                                        onSelectionChanged: _onSelectionChanged,
                                        selectionMode:
                                        DateRangePickerSelectionMode.range,
                                        initialSelectedRange: PickerDateRange(
                                          DateTime.now().subtract(
                                              const Duration(days: 1)),
                                          DateTime.now()
                                              .add(const Duration(days: 1)),
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (currentfilter == 'Doctors name') ...[
                                    Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('doctors')
                                            .snapshots(),
                                        builder: (context,
                                            AsyncSnapshot<QuerySnapshot>
                                            snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                CircularProgressIndicator());
                                          }
                                          if (snapshot.hasError) {
                                            // ignore: avoid_print
                                            print(
                                                'Error fetching data: ${snapshot.error}');
                                            return const Center(
                                                child: Text(
                                                    'Error fetching data'));
                                          }

                                          if (snapshot.hasData &&
                                              snapshot.data!.docs.isEmpty) {
                                            return const Center(
                                                child:
                                                Text('No Doctors found'));
                                          }
                                          return ListView.builder(
                                              itemCount:
                                              snapshot.data!.docs.length,
                                              itemBuilder: (context, index) {
                                                final doctorsdata =
                                                snapshot.data!.docs[index];
                                                final name =
                                                doctorsdata['name'];
                                                // final uid = doctorsdata['uid'];
                                                // final type = doctorsdata['type'];
                                                // final url =
                                                // doctorsdata['imageurl'];
                                                // final available =
                                                // doctorsdata['available'];
                                                // final rating =
                                                doctorsdata['rating'];

                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Material(
                                                    elevation: 4,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        15),
                                                    child: Card(
                                                      color:
                                                      const Color.fromARGB(
                                                          136, 79, 34, 153),
                                                      shadowColor:
                                                      const Color.fromARGB(
                                                          24, 99, 69, 155),
                                                      elevation: 15,
                                                      child: ListTile(
                                                          onTap: () {
                                                            print(selectedname);
                                                            setState(() {
                                                              selectedname =
                                                                  name;
                                                              fectcQuery(
                                                                  selectedname!);
                                                            });
                                                          },
                                                          contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              16,
                                                              vertical: 12),
                                                          leading: Text(
                                                            name,
                                                            maxLines: 2,
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            style:
                                                            const TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontSize: 18,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                          trailing:
                                                          CircleAvatar(
                                                            radius: 10,
                                                            child: CircleAvatar(
                                                                radius: 8,
                                                                backgroundColor:
                                                                selectedname ==
                                                                    name
                                                                    ? Colors
                                                                    .green
                                                                    : Colors
                                                                    .black),
                                                          )),
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  );
                },
                icon: Icon(Icons.tune))
        ],
        title: Text(
          'Appointments list',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          if (widget.data['roles'] == 'patient') ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  print(searchController.text);
                  searchQuery();
                },
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.search),
                  hintText: "Search...",
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                      BorderSide(color: Colors.deepPurple, width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      BorderSide(color: Colors.deepPurple, width: 3)),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        height: 50,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                WidgetStatePropertyAll(Colors.deepPurple)),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AppointmentsPage(data: widget.data)));
                            },
                            child: Text(
                              "book now",
                              style: TextStyle(color: Colors.white),
                            )),
                      )),
                )
              ],
            ),
          ],
          SizedBox(
            height: 5,
          ),
          Container(
            height: widget.data['roles'] == 'patient'
                ? 525
                : MediaQuery.of(context).size.height * 0.87,
            child: StreamBuilder(
              stream: query!.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  // ignore: avoid_print
                  print('Error fetching data: ${snapshot.error}');
                  return const Center(child: Text('Error fetching data'));
                }

                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No Appointments found found'));
                }
                return SizedBox(
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final appointmentdata = snapshot.data!.docs[index];
                        final appointmentid = appointmentdata['appointmentid'];
                        return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 4), // Add vertical spacing here
                            child: Appointmentshowtile(
                              appointmentdata: appointmentdata,
                              userdata: widget.data,
                              ontap: () {},
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(appointmentid)
                                    .delete();
                              },
                            ));
                      }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Appointmentshowtile extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> appointmentdata;

  final void Function()? onPressed;
  final void Function()? ontap;
  final Map userdata;
  const Appointmentshowtile({
    super.key,
    required this.appointmentdata,
    required this.userdata,
    required this.onPressed,
    required this.ontap,
  });

  @override
  State<Appointmentshowtile> createState() => _MedicalRecordTileState();
}

class _MedicalRecordTileState extends State<Appointmentshowtile> {
  void showdialogform(double screenwidth, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            insetPadding: EdgeInsets.all(15),
            child: DialogAppointmentcontainer(
              reason: widget.appointmentdata['reason'],
              appointmentid: widget.appointmentdata['appointmentid'],
              note: widget.appointmentdata['note'],
              status: widget.appointmentdata['status'],
              userdata: widget.userdata,
              date: date,
              age: widget.appointmentdata['patientage'],
              gender: widget.appointmentdata['gender'],
              description: widget.appointmentdata['description'],
              rating: widget.appointmentdata['rating'],
              url: widget.appointmentdata['doctorimageurl'],
              name: widget.userdata['roles'] == 'patient'
                  ? widget.appointmentdata['doctorsname']
                  : widget.appointmentdata['patientname'],
              type: widget.appointmentdata['type'],
              approved: widget.appointmentdata['approved'],
              onPressed: () {
                Navigator.pop(context);
              },
              screenwidth: screenwidth,
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.appointmentdata['date'].toDate();
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        color: const Color.fromARGB(136, 79, 34, 153),
        shadowColor: const Color.fromARGB(24, 99, 69, 155),
        elevation: 15,
        child: InkWell(
          onTap: () {
            showdialogform(MediaQuery.of(context).size.width, date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userdata['roles'] == 'patient'
                          ? widget.appointmentdata['doctorsname']
                          : widget.appointmentdata['patientname'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.appointmentdata['reason'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month),
                            Text(
                              DateFormat("dd/MM/yyyy").format(date),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.alarm),
                            Text(
                              widget.appointmentdata['timeslot'],
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                (widget.appointmentdata['approved'] ||
                    widget.appointmentdata['status'] != "null")
                    ? Column(
                  children: [
                    IconButton(
                        onPressed: () async {
                          final pdf = pw.Document();

                          pdf.addPage(pw.Page(
                              pageFormat: PdfPageFormat.a4,
                              build: (pw.Context context) {
                                return pw.Center(
                                  child: pw.Text("Hello World"),
                                ); // Center
                              }));
                          // Page
                          generatePdf(
                              reason: widget.appointmentdata['reason'],
                              appointmentid:
                              widget.appointmentdata['appointmentid'],
                              note: widget.appointmentdata['note'],
                              status: widget.appointmentdata['status'],
                              userdata: widget.userdata,
                              date: date,
                              age: widget.appointmentdata['patientage'],
                              gender: widget.appointmentdata['gender'],
                              description:
                              widget.appointmentdata['description'],
                              rating: widget.appointmentdata['rating'],
                              url: widget
                                  .appointmentdata['doctorimageurl'],
                              name: widget.userdata['roles'] == 'patient'
                                  ? widget.appointmentdata['doctorsname']
                                  : widget.appointmentdata['patientname'],
                              type: widget.appointmentdata['type'],
                              approved:
                              widget.appointmentdata['approved']);
                        },
                        icon: Icon(Icons.download)),
                    Text(
                      widget.appointmentdata['status'],
                      style: TextStyle(
                          color: widget.appointmentdata['status'] ==
                              "Approved"
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 19),
                    ),
                  ],
                )
                    : widget.userdata['roles'] == 'patient'
                    ? ElevatedButton(
                  onPressed: widget.onPressed,
                  child: Text(
                    'Delete',
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: IconButton(
                          tooltip: "Accept",
                          icon: const Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            try {
                              FirebaseFirestore.instance
                                  .collection("appointments")
                                  .doc(widget.appointmentdata[
                              'appointmentid'])
                                  .update({
                                'status': "Approved",
                                'approved': true,
                                'code': 'b',
                              });
                              print("status updated");
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: IconButton(
                          tooltip: "Reject",
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            try {
                              FirebaseFirestore.instance
                                  .collection("appointments")
                                  .doc(widget.appointmentdata[
                              'appointmentid'])
                                  .update({
                                'status': "Rejected",
                                'approved': false,
                                'code': 'c'
                              });
                              print("status updated");
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DialogAppointmentcontainer extends StatefulWidget {
  final double screenwidth;
  final Map userdata;
  final double rating;
  final String url;
  final String age;
  final String name;
  final String type;
  final String description;
  final String gender;
  final DateTime date;
  final String appointmentid;
  final void Function()? onPressed;
  final bool approved;
  final String status;
  final String note;
  final String reason;
  const DialogAppointmentcontainer({
    super.key,
    required this.status,
    required this.age,
    required this.appointmentid,
    required this.note,
    required this.reason,
    required this.userdata,
    required this.date,
    required this.gender,
    required this.description,
    required this.screenwidth,
    required this.rating,
    required this.url,
    required this.name,
    required this.type,
    required this.approved,
    required this.onPressed,
  });

  @override
  State<DialogAppointmentcontainer> createState() => _DialogContainerState();
}

class _DialogContainerState extends State<DialogAppointmentcontainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 650,
      width: widget.screenwidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Appointment Details",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.userdata['roles'] == 'patient')
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: FileImage(File(widget.url)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.type,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        (widget.status != "null")
                            ? Text(
                          widget.status,
                          style: TextStyle(
                              color: widget.status == "Approved"
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        )
                            : Text(
                          "Not Approved",
                          style: TextStyle(color: Colors.red),
                        )
                      ]),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.rating} ★",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 30),
            const Text(
              "Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            DetailRow(label: "Full Name", value: widget.name),
            const SizedBox(height: 10),
            DetailRow(label: "Age", value: widget.age),
            const SizedBox(height: 10),
            DetailRow(label: "Gender", value: "Male"),
            const SizedBox(height: 10),
            DetailRow(label: "Purpose of Visit", value: widget.reason),
            const SizedBox(height: 10),
            DetailRow(
                label: "Date",
                value: DateFormat('dd-MM-yyyy').format(widget.date)),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Describe Condition:",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                if (widget.userdata['roles'] == 'doctor' &&
                    widget.status == 'Approved' &&
                    widget.note == "") ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(widget.appointmentid)
                                .update({
                              'note': "requsted for a Surgery",
                              'prescribed': 'surgery'
                            });
                            Navigator.pop(context);
                          },
                          child: Text("Surgery")),
                      SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(widget.appointmentid)
                                .update({
                              'note': "requsted for a Admit",
                              'prescribed': 'admit'
                            });
                            Navigator.pop(context);
                          },
                          child: Text("Admit"))
                    ],
                  )
                ],
                if (widget.status == 'Approved' && widget.note != "") ...[
                  Text(
                    "Prescribed:",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  if (widget.userdata['roles'] == 'doctor')
                    Text(
                      'you have ${widget.note}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  SizedBox(
                    height: 5,
                  ),
                  if (widget.userdata['roles'] == 'patient' &&
                      widget.status == 'Approved' &&
                      widget.note != '') ...[
                    Text("${widget.name} has requested for a surgery")
                  ]
                ],
              ],
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

Future<void> generatePdf({
  required Map userdata,
  required double rating,
  required String url,
  required String age,
  required String name,
  required String type,
  required String description,
  required String gender,
  required DateTime date,
  required String appointmentid,
  required bool approved,
  required String status,
  required String note,
  required String reason,
  BuildContext? context,
}) async {
  final pdf = pw.Document();

  final image = pw.MemoryImage(
    File(url).readAsBytesSync(),
  );

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(20),
          boxShadow: [
            pw.BoxShadow(
              spreadRadius: 3,
              blurRadius: 10,
            ),
          ],
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text(
                  "Appointment Details",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                pw.Spacer(),
              ],
            ),
            pw.SizedBox(height: 20),
            if (userdata['roles'] == 'patient')
              pw.Row(
                children: [
                  pw.Container(
                    width: 70,
                    height: 70,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      image: pw.DecorationImage(
                          image: image, fit: pw.BoxFit.cover),
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        name,
                        style: pw.TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        type,
                        style: pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        status != "null" ? status : "Not Approved",
                        style: pw.TextStyle(
                          color: status == "Approved"
                              ? PdfColor(0, 100, 0)
                              : PdfColor(100, 0, 0),
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Text(
                    "$rating ★",
                    style: pw.TextStyle(
                      color: PdfColor(50, 50, 0),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            pw.SizedBox(height: 30),
            pw.Text(
              "Details",
              style: pw.TextStyle(
                fontSize: 20,
              ),
            ),
            pw.SizedBox(height: 15),
            detailRow("Full Name", name),
            detailRow("Age", age),
            detailRow("Gender", gender),
            detailRow("Purpose of Visit", reason),
            detailRow("Date", "${date.day}-${date.month}-${date.year}"),
            pw.SizedBox(height: 10),
            pw.Text(
              "Describe Condition:",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
              ),
            ),
            pw.Text(
              description,
              style: pw.TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    ),
  );
  await Printing.sharePdf(bytes: await pdf.save(), filename: 'my-document.pdf');
}

pw.Widget detailRow(String label, String value) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      pw.Text(
        value,
        style: pw.TextStyle(fontSize: 16),
      ),
    ],
  );
}