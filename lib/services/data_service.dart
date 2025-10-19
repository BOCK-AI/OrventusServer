import 'dart:math';
import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/driver.dart';
import '../models/vehicle.dart';
import '../models/promo_code.dart';
import '../models/document.dart';

class DataService {
  // Singleton pattern
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // In-memory storage
  final List<Customer> _customers = [];
  final List<Driver> _drivers = [];
  final List<Vehicle> _vehicles = [];
  final List<PromoCode> _promoCodes = [];
  final List<DocumentType> _documents = [];

  // Initialize with mock data
  void initializeMockData() {
    if (_customers.isEmpty) {
      _initializeCustomers();
      _initializeDrivers();
      _initializeVehicles();
      _initializePromoCodes();
      _initializeDocuments();
    }
  }

  void _initializeCustomers() {
    for (int i = 0; i < 25; i++) {
      _customers.add(Customer(
        id: 'CUST${1000 + i}',
        name: 'Customer ${i + 1}',
        email: 'customer${i + 1}@email.com',
        contact: '+91${9000000000 + i}',
        walletBalance: Random().nextInt(5000).toDouble(),
        rating: (3 + Random().nextDouble() * 2),
        isActive: true,
      ));
    }
  }

  void _initializeDrivers() {
    for (int i = 0; i < 25; i++) {
      _drivers.add(Driver(
        id: 'DRV${2000 + i}',
        name: 'Driver ${i + 1}',
        email: 'driver${i + 1}@email.com',
        contact: '+91${9100000000 + i}',
        totalVehicles: Random().nextInt(3) + 1,
        rating: (4.0 + Random().nextDouble()),
        totalTrips: Random().nextInt(200),
        isActive: true,
        isApproved: true,
      ));
    }
  }

  void _initializeVehicles() {
    _vehicles.addAll([
      Vehicle(
        id: 'VEH001',
        name: 'Go Non AC',
        costPerKm: 8.0,
        icon: Icons.directions_car,
        isActive: true,
      ),
      Vehicle(
        id: 'VEH002',
        name: 'Orventus Go',
        costPerKm: 10.0,
        icon: Icons.local_taxi,
        isActive: true,
      ),
      Vehicle(
        id: 'VEH003',
        name: 'Premier',
        costPerKm: 15.0,
        icon: Icons.drive_eta,
        isActive: true,
      ),
      Vehicle(
        id: 'VEH004',
        name: 'XL+',
        costPerKm: 18.0,
        icon: Icons.airport_shuttle,
        isActive: true,
      ),
      Vehicle(
        id: 'VEH005',
        name: 'Orventus Pet',
        costPerKm: 12.0,
        icon: Icons.pets,
        isActive: true,
      ),
      Vehicle(
        id: 'VEH006',
        name: 'Orventus AVT',
        costPerKm: 6.0,
        icon: Icons.electric_rickshaw,
        isActive: true,
      ),
    ]);
  }

  void _initializePromoCodes() {
    _promoCodes.addAll([
      PromoCode(
        id: 'PROMO001',
        code: 'MONSOON',
        usageLimit: 50,
        totalUsed: 5,
        expiryDate: '2025-10-30',
        discountValue: 100,
        discountType: 'amount',
        isActive: true,
      ),
      PromoCode(
        id: 'PROMO002',
        code: 'MINIMUM',
        usageLimit: 100,
        totalUsed: 9,
        expiryDate: '2025-12-25',
        discountValue: 15,
        discountType: 'percentage',
        isActive: true,
      ),
      PromoCode(
        id: 'PROMO003',
        code: 'PROMO20',
        usageLimit: 90,
        totalUsed: 28,
        expiryDate: '2025-05-14',
        discountValue: 20,
        discountType: 'percentage',
        isActive: true,
      ),
    ]);
  }

  void _initializeDocuments() {
    _documents.addAll([
      DocumentType(
        id: 'DOC001',
        name: "Driver's License",
        requiresExpiry: true,
        isActive: true,
      ),
      DocumentType(
        id: 'DOC002',
        name: 'Insurance',
        requiresExpiry: true,
        isActive: true,
      ),
      DocumentType(
        id: 'DOC003',
        name: 'Vehicle Registration',
        requiresExpiry: true,
        isActive: true,
      ),
      DocumentType(
        id: 'DOC004',
        name: 'ID Proof',
        requiresExpiry: false,
        isActive: true,
      ),
      DocumentType(
        id: 'DOC005',
        name: 'Address Proof',
        requiresExpiry: false,
        isActive: true,
      ),
    ]);
  }

  // Customer CRUD operations
  List<Customer> getAllCustomers() => List.unmodifiable(_customers);
  
  void addCustomer(Customer customer) {
    _customers.add(customer);
  }

  void updateCustomer(String id, Customer updatedCustomer) {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index != -1) {
      _customers[index] = updatedCustomer;
    }
  }

  void deleteCustomer(String id) {
    _customers.removeWhere((c) => c.id == id);
  }

  // Driver CRUD operations
  List<Driver> getAllDrivers() => List.unmodifiable(_drivers);
  
  void addDriver(Driver driver) {
    _drivers.add(driver);
  }

  void updateDriver(String id, Driver updatedDriver) {
    final index = _drivers.indexWhere((d) => d.id == id);
    if (index != -1) {
      _drivers[index] = updatedDriver;
    }
  }

  void deleteDriver(String id) {
    _drivers.removeWhere((d) => d.id == id);
  }

  // Vehicle CRUD operations
  List<Vehicle> getAllVehicles() => List.unmodifiable(_vehicles);
  
  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
  }

  void updateVehicle(String id, Vehicle updatedVehicle) {
    final index = _vehicles.indexWhere((v) => v.id == id);
    if (index != -1) {
      _vehicles[index] = updatedVehicle;
    }
  }

  void deleteVehicle(String id) {
    _vehicles.removeWhere((v) => v.id == id);
  }

  // PromoCode CRUD operations
  List<PromoCode> getAllPromoCodes() => List.unmodifiable(_promoCodes);
  
  void addPromoCode(PromoCode promoCode) {
    _promoCodes.add(promoCode);
  }

  void updatePromoCode(String id, PromoCode updatedPromoCode) {
    final index = _promoCodes.indexWhere((p) => p.id == id);
    if (index != -1) {
      _promoCodes[index] = updatedPromoCode;
    }
  }

  void deletePromoCode(String id) {
    _promoCodes.removeWhere((p) => p.id == id);
  }

  // Document CRUD operations
  List<DocumentType> getAllDocuments() => List.unmodifiable(_documents);
  
  void addDocument(DocumentType document) {
    _documents.add(document);
  }

  void updateDocument(String id, DocumentType updatedDocument) {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index != -1) {
      _documents[index] = updatedDocument;
    }
  }

  void deleteDocument(String id) {
    _documents.removeWhere((d) => d.id == id);
  }

  // Generate unique IDs
  String generateCustomerId() => 'CUST${1000 + _customers.length}';
  String generateDriverId() => 'DRV${2000 + _drivers.length}';
  String generateVehicleId() => 'VEH${(_vehicles.length + 1).toString().padLeft(3, '0')}';
  String generatePromoCodeId() => 'PROMO${(_promoCodes.length + 1).toString().padLeft(3, '0')}';
  String generateDocumentId() => 'DOC${(_documents.length + 1).toString().padLeft(3, '0')}';
}