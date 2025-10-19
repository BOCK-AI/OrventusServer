// lib/screens/dashboard/components/total_order_services_card.dart

import 'package:flutter/material.dart';

class TotalOrderServicesCard extends StatelessWidget {
  // This widget now expects to receive the live data from the backend
  final Map<String, int> orderServices;
  const TotalOrderServicesCard({Key? key, required this.orderServices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We create a list of all possible services to ensure a consistent order
    // and to show services that might have 0 rides.
    final allServices = [
      'Go Non AC',
      'Orventus Go',
      'Premier',
      'XL+ (Innova)',
      'Orventus Pet',
      'Orventus AVT' // Adding any others that might appear
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Order Of Services",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16.0),
          // Use Wrap to handle different screen sizes
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            // We now map over our defined list of all services
            children: allServices.map((serviceName) {
              // Get the count from the live data, or default to 0 if it doesn't exist
              final count = orderServices[serviceName] ?? 0;
              
              // Only show the card if there are rides for it (optional, but cleaner)
              if (count > 0) {
                return ServiceCard(
                  title: serviceName,
                  rides: count,
                );
              }
              // If you want to show all cards even with 0 rides,
              // you can just return the ServiceCard directly without the 'if'
              return ServiceCard(title: serviceName, rides: count);

            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final int rides;

  const ServiceCard({
    Key? key,
    required this.title,
    required this.rides,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          const Icon(Icons.drive_eta, size: 40, color: Colors.black54),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text("$rides Rides"),
        ],
      ),
    );
  }
}