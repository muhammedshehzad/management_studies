import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TeachersList extends StatelessWidget {
  const TeachersList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'Teacher')
          .orderBy('username')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: SizedBox());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No teachers found.'));
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String username = data['username'] ?? 'No Name';
              final String email = data['email'] ?? 'No Email';
              final String phone = data['phone'] ?? 'No Phone';
              final String department = data['department'] ?? 'Unknown';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: Colors.white,
                elevation: 2.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade400,
                          radius: 25,
                          child: Text(
                            username.isNotEmpty ? username[0] : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Email: $email\nDepartment: $department\nPhone: $phone',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class TeachersChart extends StatelessWidget {
  const TeachersChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'Teacher')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: SizedBox());
        }

        Map<String, int> departmentCounts = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          String department = data['department'] ?? 'Unknown';
          if (department != 'Unknown') {
            departmentCounts[department] =
                (departmentCounts[department] ?? 0) + 1;
          }
        }

        List<String> departments = departmentCounts.keys.toList()..sort();

        List<BarChartGroupData> barGroups = [];
        for (int i = 0; i < departments.length; i++) {
          String department = departments[i];
          int count = departmentCounts[department]!;
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: Colors.teal.shade400,
                  borderRadius: BorderRadius.circular(1),
                ),
              ],
              barsSpace: 4,
            ),
          );
        }

        double computedMax = 0;
        for (var value in departmentCounts.values) {
          if (value.toDouble() > computedMax) {
            computedMax = value.toDouble();
          }
        }
        double maxY = computedMax < 5 ? 5 : computedMax + 1;

        return Container(
          height: 280,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.5),
                blurRadius: 8,
                offset: const Offset(1, 4),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 20,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < departments.length) {
                          String displayText = departments[index].length > 8
                              ? departments[index].substring(0, 4)
                              : departments[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: 70,
                              child: Text(
                                displayText,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        if (index >= 0) {
                          return Container(
                            width: 70,
                            alignment: Alignment.center,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  )),
            ),
          ),
        );
      },
    );
  }
}
