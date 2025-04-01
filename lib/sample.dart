import 'dart:ui';
import 'package:flutter/material.dart';

class SamplePage extends StatefulWidget {
  const SamplePage({super.key});

  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.defaultPadding),
                StatisticWidget(salesMade: 142, deliveriesCompleted: 123),
                const SizedBox(height: AppConstants.cardSpacing),
                DashboardPage(),
                const SizedBox(height: AppConstants.cardSpacing),
                SummaryWidget(
                  sessionTitle: 'Team Meeting',
                  sessionDate: 'March 15, 2025',
                  requirements:
                      'Prepare quarterly report and update project status.',
                ),
                const SizedBox(height: AppConstants.cardSpacing),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding),
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Daily report shared!'))),
                    icon: const Icon(Icons.share),
                    label: const Text('Share Daily Report'),
                  ),
                ),
                const SizedBox(height: AppConstants.sectionSpacing),
                _buildSectionTitle(context, 'Itemized List'),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildDataTable(),
                const SizedBox(height: AppConstants.sectionSpacing),
                _buildSectionTitle(context, 'Tax and Discount Details'),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildExpansionPanel(),
                const SizedBox(height: AppConstants.sectionSpacing),
                _buildSectionTitle(context, 'Total Calculation'),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildTotalCalculator(),
                const SizedBox(height: AppConstants.sectionSpacing),
                _buildSectionTitle(context, 'Payment Summary'),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildPaymentSummary(),
                const SizedBox(height: AppConstants.sectionSpacing),
                _buildMapSection(),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  // Updated map section with better styling
  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Card(
        child: Stack(
          children: [
            _buildMapWidget(),
            _buildRouteOverlay(),
          ],
        ),
      ),
    );
  }

  // Updated map widget with realistic placeholder
  Widget _buildMapWidget() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Interactive Map Placeholder',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  // Updated route overlay with  shadow and typography
  Widget _buildRouteOverlay() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'Optimized Delivery Route Placeholder',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Item')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Price')),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('Item A')),
              DataCell(Text('2')),
              DataCell(Text('\$50')),
            ]),
            DataRow(cells: [
              DataCell(Text('Item B')),
              DataCell(Text('1')),
              DataCell(Text('\$30')),
            ]),
          ],
        ),
      ),
    );
  }

  // Updated expansion panel with animation
  Widget _buildExpansionPanel() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Card(
        child: ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {}); // Update state for animation
          },
          children: [
            ExpansionPanel(
              isExpanded: true,
              headerBuilder: (context, isExpanded) => ListTile(
                title: Text(
                  'Tax & Discount Breakdown',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Tax: \$8\nDiscount: \$5',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated total calculator
  Widget _buildTotalCalculator() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subtotal: \$80',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('Tax: \$8', style: Theme.of(context).textTheme.bodyMedium),
              Text('Discount: \$5',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('Grand Total: \$83',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }

  // Updated payment summary
  Widget _buildPaymentSummary() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Method: Credit Card',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('Transaction ID: TXN12345678',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticWidget extends StatelessWidget {
  final int salesMade;
  final int deliveriesCompleted;

  const StatisticWidget({
    Key? key,
    required this.salesMade,
    required this.deliveriesCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                'Sales Made',
                salesMade,
                Icons.shopping_cart,
              ),
              _buildStatItem(
                context,
                'Deliveries Completed',
                deliveriesCompleted,
                Icons.local_shipping,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String title, int value, IconData icon) {
    return Semantics(
      label: '$title: $value',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class SummaryWidget extends StatelessWidget {
  final String sessionTitle;
  final String sessionDate;
  final String requirements;

  const SummaryWidget({
    Key? key,
    required this.sessionTitle,
    required this.sessionDate,
    required this.requirements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session Summary',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildSummaryItem(context, 'Title', sessionTitle),
              _buildSummaryItem(context, 'Date', sessionDate),
              _buildSummaryItem(context, 'Requirements', requirements),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Daily Sales and Activity Summary',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildDataTable(context),
          const SizedBox(height: AppConstants.cardSpacing),
          Text(
            'Performance Chart',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildChartPlaceholder(),
          const SizedBox(height: AppConstants.cardSpacing),
          Text(
            'Detailed Breakdown',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildExpansionPanel(context),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Sales')),
          DataColumn(label: Text('Activity')),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('March 12, 2025')),
            DataCell(Text('\$5000')),
            DataCell(Text('12 Deliveries')),
          ]),
          DataRow(cells: [
            DataCell(Text('March 13, 2025')),
            DataCell(Text('\$6200')),
            DataCell(Text('15 Deliveries')),
          ]),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Card(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Performance Chart Placeholder',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionPanel(BuildContext context) {
    return Card(
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {},
        children: [
          ExpansionPanel(
            isExpanded: true,
            headerBuilder: (context, isExpanded) => ListTile(
              title: Text(
                'Sales Breakdown',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Detailed breakdown of sales by product and region goes here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: Colors.blueGrey,
      scaffoldBackgroundColor: Colors.grey[50],
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}

class AppConstants {
  static const double defaultPadding = 16.0;
  static const double cardSpacing = 24.0;
  static const double sectionSpacing = 32.0;
}
