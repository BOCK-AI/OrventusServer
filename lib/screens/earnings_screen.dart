// lib/screens/earnings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'earnings/earnings_provider.dart'; // We will create this
import '/models/ride_model.dart'; // We will reuse the RideModel

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EarningsProvider(),
      child: Consumer<EarningsProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(child: Text("Error: ${provider.error}"))
                    : SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration:  BoxDecoration(color: const Color.fromARGB(255, 10, 3, 3), borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Earnings Report', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              if (provider.report != null)
                                Row(
                                  children: [
                                    Expanded(child: _buildEarningCard('Total Fare', '₹${provider.report!.summary.totalFare.toStringAsFixed(2)}', Colors.blue)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildEarningCard('Site Commission', '₹${provider.report!.summary.siteCommission.toStringAsFixed(2)}', Colors.green)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildEarningCard('Driver Earnings', '₹${provider.report!.summary.driverEarnings.toStringAsFixed(2)}', Colors.orange)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildEarningCard('Total Discount', '₹${provider.report!.summary.totalDiscount.toStringAsFixed(2)}', Colors.red)),
                                  ],
                                ),
                              const SizedBox(height: 24),
                              const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Ride ID')),
                                    DataColumn(label: Text('Driver')),
                                    DataColumn(label: Text('Customer')),
                                    DataColumn(label: Text('Fare')),
                                    DataColumn(label: Text('Commission')),
                                    DataColumn(label: Text('Date')),
                                  ],
                                  rows: provider.report!.transactions.map((ride) => DataRow(
                                    cells: [
                                      DataCell(Text(ride.id.toString())),
                                      DataCell(Text(ride.rider?.name ?? 'N/A')),
                                      DataCell(Text(ride.customer?.name ?? 'N/A')),
                                      DataCell(Text('₹${ride.fare.toStringAsFixed(2)}')),
                                      DataCell(Text('₹${(ride as dynamic).commission?.toStringAsFixed(2) ?? '0.00'}')),
                                      DataCell(Text(ride.createdAt.toLocal().toString().split(' ')[0])),
                                    ],
                                  )).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          );
        },
      ),
    );
  }

  Widget _buildEarningCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}