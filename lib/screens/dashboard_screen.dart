import 'package:flutter/material.dart';
import 'dart:math';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text('Super Admin', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Today Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Revenue',
                  '₹2,095',
                  Colors.blue,
                  Icons.attach_money,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Completed Rides',
                  '12',
                  Colors.teal,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Cancelled Rides',
                  '17',
                  Colors.red,
                  Icons.cancel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Rides',
                  '31',
                  Colors.orange,
                  Icons.local_taxi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Total Order Of Services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildServiceCard('Go Non AC', '${Random().nextInt(50)} Rides'),
              _buildServiceCard('Orventus Go', '${Random().nextInt(50)} Rides'),
              _buildServiceCard('Premier', '${Random().nextInt(50)} Rides'),
              _buildServiceCard('XL+', '${Random().nextInt(50)} Rides'),
              _buildServiceCard('Orventus Pet', '${Random().nextInt(50)} Rides'),
              _buildServiceCard('Orventus AVT', '${Random().nextInt(50)} Rides'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Icon(icon, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String service, String count) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 15, 10, 10),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car, size: 40, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(service, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(count, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}