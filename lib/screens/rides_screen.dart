// lib/screens/rides_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'rides/rides_provider.dart';
import '/models/ride_model.dart';

class RidesScreen extends StatelessWidget {
  const RidesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RidesProvider>(context);
    final List<RideModel> rides = provider.rides;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rides List", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Color.fromARGB(255, 9, 1, 1), borderRadius: BorderRadius.all(Radius.circular(10))),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? Center(child: Text('Error: ${provider.error}'))
                      : DataTable(
                          columns: const [
                            DataColumn(label: Text("Ride ID")),
                            DataColumn(label: Text("Customer Name")),
                            DataColumn(label: Text("Rider Name")),
                            DataColumn(label: Text("Pickup")),
                            DataColumn(label: Text("Dropoff")),
                            DataColumn(label: Text("Fare")),
                            DataColumn(label: Text("Status")),
                          ],
                          rows: List.generate(
                            rides.length,
                            (index) {
                              final ride = rides[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text(ride.id)),
                                  // Use the null-aware operator ?? to provide a fallback
                                  DataCell(Text(ride.customer?.name ?? 'N/A')),
                                  DataCell(Text(ride.rider?.name ?? 'N/A')),
                                  DataCell(Text(ride.pickupAddress)),
                                  DataCell(Text(ride.dropoffAddress)),
                                  DataCell(Text('₹${ride.fare.toStringAsFixed(2)}')),
                                  DataCell(Text(ride.status)),
                                ],
                              );
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}