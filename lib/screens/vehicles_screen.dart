// lib/screens/vehicles_screen.dart

import 'package:flutter/material.dart';
import '/models/vehicle.dart';
import '../data/repository/vehicle_repository.dart'; // Import our new repository

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({Key? key}) : super(key: key);
  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final VehicleRepository _repo = VehicleRepository(); // Use the repository
  Future<List<Vehicle>>? _vehiclesFuture;

  final List<IconData> _availableIcons = const [
    Icons.directions_car, Icons.local_taxi, Icons.drive_eta,
    Icons.airport_shuttle, Icons.pets, Icons.electric_rickshaw,
    Icons.commute, Icons.directions_bus,
  ];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    setState(() {
      _vehiclesFuture = _repo.getAllVehicles();
    });
  }

  void _showAddEditDialog({Vehicle? vehicle}) {
    final bool isEditing = vehicle != null;
    final nameController = TextEditingController(text: vehicle?.name ?? '');
    final costController = TextEditingController(text: vehicle?.costPerKm.toString() ?? '');
    IconData selectedIcon = vehicle?.icon ?? _availableIcons[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Vehicle Type' : 'Add Vehicle Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Vehicle Name')),
                const SizedBox(height: 12),
                TextField(controller: costController, decoration: const InputDecoration(labelText: 'Cost Per Km (₹)'), keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                const Text('Select Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _availableIcons.map((icon) => GestureDetector(
                    onTap: () => setDialogState(() => selectedIcon = icon),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: selectedIcon == icon ? Colors.blue : Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 32),
                    ),
                  )).toList(),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || costController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                  return;
                }
                final newVehicle = Vehicle(
                  id: vehicle?.id ?? '', // ID is ignored by backend on create
                  name: nameController.text,
                  costPerKm: double.tryParse(costController.text) ?? 0,
                  icon: selectedIcon,
                );

                try {
                  if (isEditing) {
                    await _repo.updateVehicle(vehicle!.id, newVehicle);
                  } else {
                    await _repo.addVehicle(newVehicle);
                  }
                  _loadVehicles();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Vehicle updated' : 'Vehicle added')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteVehicle(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _repo.deleteVehicle(vehicle.id);
                _loadVehicles();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle deleted')));
              } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Vehicle Type List", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: _showAddEditDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Vehicle Type'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              )
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FutureBuilder<List<Vehicle>>(
                future: _vehiclesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No vehicles found. Click 'Add Vehicle Type' to create one."));
                  }
                  final vehicles = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5,
                    ),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(vehicle.icon, size: 48, color: Colors.blue),
                            const SizedBox(height: 8),
                            Text(vehicle.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Cost Per Km: ₹${vehicle.costPerKm.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: () => _showAddEditDialog(vehicle: vehicle)),
                                IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteVehicle(vehicle)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}