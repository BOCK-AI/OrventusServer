// lib/models/vehicle.dart

import 'package:flutter/material.dart';

// Helper function to map string names from backend to real Flutter IconData
IconData iconFromString(String iconName) {
  switch (iconName) {
    case 'directions_car': return Icons.directions_car;
    case 'local_taxi': return Icons.local_taxi;
    case 'drive_eta': return Icons.drive_eta;
    case 'airport_shuttle': return Icons.airport_shuttle;
    case 'pets': return Icons.pets;
    case 'electric_rickshaw': return Icons.electric_rickshaw;
    case 'commute': return Icons.commute;
    case 'directions_bus': return Icons.directions_bus;
    default: return Icons.help_outline; // A fallback icon
  }
}

// Helper function to map IconData back to a string for sending to the backend
String stringFromIcon(IconData icon) {
  if (icon == Icons.directions_car) return 'directions_car';
  if (icon == Icons.local_taxi) return 'local_taxi';
  if (icon == Icons.drive_eta) return 'drive_eta';
  if (icon == Icons.airport_shuttle) return 'airport_shuttle';
  if (icon == Icons.pets) return 'pets';
  if (icon == Icons.electric_rickshaw) return 'electric_rickshaw';
  if (icon == Icons.commute) return 'commute';
  if (icon == Icons.directions_bus) return 'directions_bus';
  return 'help_outline';
}

class Vehicle {
  String id;
  String name;
  double costPerKm;
  IconData icon;
  bool isActive;

  Vehicle({
    required this.id,
    required this.name,
    required this.costPerKm,
    required this.icon,
    this.isActive = true,
  });

  // New factory constructor to parse JSON from the backend
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'].toString(),
      name: json['name'],
      costPerKm: (json['costPerKm'] as num).toDouble(),
      icon: iconFromString(json['icon']),
      isActive: json['isActive'] ?? true,
    );
  }

  // Updated toJson method to send data to the backend
  Map<String, dynamic> toJson() {
    return {
      // 'id' is not needed when creating/updating, the server handles it
      'name': name,
      'costPerKm': costPerKm,
      'icon': stringFromIcon(icon),
      'isActive': isActive,
    };
  }
}