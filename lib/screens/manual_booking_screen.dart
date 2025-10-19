// lib/screens/manual_booking_screen.dart

import 'package:flutter/material.dart';
import '../data/repository/ride_repository.dart'; // <-- CORRECT IMPORT

class ManualBookingScreen extends StatefulWidget {
  const ManualBookingScreen({Key? key}) : super(key: key);
  @override
  State<ManualBookingScreen> createState() => _ManualBookingScreenState();
}

class _ManualBookingScreenState extends State<ManualBookingScreen> {
  // --- CORRECT REPOSITORY ---
  final RideRepository _rideRepo = RideRepository();
  bool _isLoading = false;

  final _customerContactController = TextEditingController();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  String _selectedVehicle = 'Go Non AC';

  @override
  void dispose() {
    _customerContactController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
  
  // --- CORRECTED BOOK RIDE FUNCTION ---
  void _bookRide() async {
    if (_customerContactController.text.isEmpty || _pickupController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }
    setState(() { _isLoading = true; });
    try {
      await _rideRepo.createRideAsAdmin(
        pickupAddress: _pickupController.text,
        dropoffAddress: _destinationController.text,
        vehicle: _selectedVehicle,
        fare: 250.0, // Placeholder fare
        customerPhone: _customerContactController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ride booked successfully!'), backgroundColor: Colors.green));
        _customerContactController.clear();
        _pickupController.clear();
        _destinationController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This is a simplified version of your UI, focusing on the logic
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manual Ride Booking', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildTextField(_customerContactController, 'Customer Contact No.'),
          const SizedBox(height: 16),
          _buildTextField(_pickupController, 'Pickup Address'),
          const SizedBox(height: 16),
          _buildTextField(_destinationController, 'Destination Address'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            items: ['Go Non AC', 'Orventus Go', 'Premier', 'XL+'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            value: _selectedVehicle,
            onChanged: (value) => setState(() => _selectedVehicle = value ?? 'Go Non AC'),
            decoration: const InputDecoration(labelText: 'Vehicle Type'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _bookRide,
            child: _isLoading ? const CircularProgressIndicator() : const Text('Book Ride'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }
}