// lib/screens/reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reviews/reviews_provider.dart'; // We will create this
import '/models/review_model.dart'; // We will create this

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReviewsProvider(),
      child: Consumer<ReviewsProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  color: const Color.fromARGB(255, 12, 7, 7),
                  child: Row(
                    children: [
                      Text("Driver's Review List", style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(color: const Color.fromARGB(255, 13, 6, 6), borderRadius: BorderRadius.circular(8)),
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : provider.error != null
                              ? Center(child: Text("Error: ${provider.error}"))
                              : DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Booking ID')),
                                    DataColumn(label: Text('Customer Name')),
                                    DataColumn(label: Text('Driver Name')),
                                    DataColumn(label: Text('Date & Time')),
                                    DataColumn(label: Text('Rating')),
                                    DataColumn(label: Text('Comments')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: provider.reviews.map((review) => DataRow(
                                    cells: [
                                      DataCell(Text(review.rideId.toString())),
                                      DataCell(Text(review.customerName)),
                                      DataCell(Text(review.driverName)),
                                      DataCell(Text(review.createdAt.toLocal().toString().split('.')[0])),
                                      DataCell(Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), Text(' ${review.rating.toStringAsFixed(1)}')])),
                                      DataCell(Text(review.comment ?? 'No comment')),
                                      DataCell(IconButton(icon: const Icon(Icons.visibility, size: 18), onPressed: () {})),
                                    ],
                                  )).toList(),
                                ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}