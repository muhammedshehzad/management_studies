import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AcademicPerformanceChart extends StatelessWidget {
  const AcademicPerformanceChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('records').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: SizedBox());
        }
        Map<String, List<double>> groupedData = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          String academicYear = data['academicyear'] ?? "Unknown";
          double score = data['score'] is int
              ? (data['score'] as int).toDouble()
              : data['score'] as double;
          if (!groupedData.containsKey(academicYear)) {
            groupedData[academicYear] = [];
          }
          groupedData[academicYear]!.add(score);
        }
        List<AcademicPerformance> performanceData = [];
        groupedData.forEach((year, scores) {
          double avg = scores.reduce((a, b) => a + b) / scores.length;
          double averageScore = double.parse(avg.toStringAsFixed(2));
          performanceData.add(AcademicPerformance(
            academicYear: year,
            averageScore: averageScore,
          ));
        });
        performanceData
            .sort((a, b) => a.academicYear.compareTo(b.academicYear));
        return Container(
          padding: const EdgeInsets.only(right: 16.0, bottom: 5),
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(1, 4),
              ),
            ],
          ),
          width: double.infinity,
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Average Scores Over Academic Years',
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            primaryXAxis: CategoryAxis(
              maximumLabelWidth: 80,
              title: AxisTitle(
                text: 'Academic Year',
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            primaryYAxis: NumericAxis(
              interval: 200,
              title: AxisTitle(
                text: 'Average Score',
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            series: <CartesianSeries>[
              LineSeries<AcademicPerformance, String>(
                color: Colors.teal.shade300,
                dataSource: performanceData,
                xValueMapper: (AcademicPerformance data, _) =>
                    data.academicYear,
                yValueMapper: (AcademicPerformance data, _) =>
                    data.averageScore,
                markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 4,
                    width: 4,
                    borderColor: Colors.blueGrey[300],
                    color: Colors.blueGrey[200]),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 12),
                ),
                name: 'Average Score',
              ),
            ],
          ),
        );
      },
    );
  }
}

class GradeDistributionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('records').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: SizedBox());
        }

        Map<String, int> gradeMap = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          String grade = data['grade'] ?? 'Unknown';
          gradeMap[grade] = (gradeMap[grade] ?? 0) + 1;
        }

        List<GradeCount> chartData = gradeMap.entries
            .map((entry) => GradeCount(grade: entry.key, count: entry.value))
            .toList();

        chartData.sort((a, b) => a.grade.compareTo(b.grade));

        return Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 8,
                offset: Offset(1, 4),
              ),
            ],
          ),
          width: double.infinity,
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Grade Distribution',
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            primaryXAxis: CategoryAxis(
              title: AxisTitle(
                text: 'Grade',
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            primaryYAxis: NumericAxis(
              interval: 1,
              title: AxisTitle(
                text: 'Number of Students',
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            series: <CartesianSeries>[
              ColumnSeries<GradeCount, String>(
                dataSource: chartData,
                xValueMapper: (GradeCount data, _) => data.grade,
                yValueMapper: (GradeCount data, _) => data.count,
                name: 'Students',
                width: 0.6,
                color: Colors.green.shade400,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DepartmentDistributionDonutChart extends StatelessWidget {
  const DepartmentDistributionDonutChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'Student')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: SizedBox());
        }

        Map<String, int> departmentCounts = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          String department = data['department'] ?? 'Unknown';
          String role = data['role'] ?? 'Unknown';
          departmentCounts[department] =
              (departmentCounts[department] ?? 0) + 1;
        }

        List<DepartmentCount> chartData = departmentCounts.entries
            .map((entry) =>
                DepartmentCount(department: entry.key, count: entry.value))
            .toList();

        chartData.sort((a, b) => a.department.compareTo(b.department));

        final List<Color> minimalistColors = [
          Color(0xFF80CBC4),
          Color(0xFF90CAF9),
          Color(0xFFF48FB1),
          Color(0xFFA5D6A7),
          Color(0xFFFFCC80),
          Color(0xFFB39DD0),
        ];

        return Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(1, 4),
              ),
            ],
          ),
          width: double.infinity,
          child: SfCircularChart(
            title: ChartTitle(
              text: 'Students by Department',
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            legend: Legend(
              isVisible: true,
              padding: 5,
              overflowMode: LegendItemOverflowMode.scroll,
              position: LegendPosition.bottom,
              backgroundColor: Colors.blueGrey.shade50,
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CircularSeries>[
              DoughnutSeries<DepartmentCount, String>(
                animationDuration: 800,
                dataSource: chartData,
                xValueMapper: (DepartmentCount data, _) => data.department,
                yValueMapper: (DepartmentCount data, _) => data.count,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                innerRadius: '40%',
                // Assign a different minimalist color to each slice.
                pointColorMapper: (DepartmentCount data, int? index) =>
                    minimalistColors[index! % minimalistColors.length],
                name: 'Students',
              ),
            ],
          ),
        );
      },
    );
  }
}

class GradeCount {
  final String grade;
  final int count;

  GradeCount({required this.grade, required this.count});
}

class AcademicPerformance {
  final String academicYear;
  final double averageScore;

  AcademicPerformance({required this.academicYear, required this.averageScore});
}

class DepartmentCount {
  final String department;
  final int count;

  DepartmentCount({required this.department, required this.count});
}
