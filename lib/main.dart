import 'package:flutter/material.dart';
import 'package:orventus_admin/screens/notifications/notifications_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'screens/dashboard/dashboard_provider.dart';
import 'screens/customers/users_provider.dart';

// Import all the screen widgets
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/drivers_screen.dart';
import 'screens/rides_screen.dart';
import 'screens/vehicles_screen.dart';
import 'screens/promo_codes_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/earnings_screen.dart';
import 'screens/manual_booking_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/notifications_screen.dart';

import 'data/repository/auth_repository.dart'; // Import for Login Screen
import 'screens/rides/rides_provider.dart'; // <-- Add this import
import 'screens/earnings/earnings_provider.dart';
import 'screens/reviews/reviews_provider.dart'; // <-- Add this import
import 'screens/settings/settings_provider.dart';
import 'screens/notifications_screen.dart';

void main() {
  runApp(const OrventusAdminApp());
}

class OrventusAdminApp extends StatelessWidget {
  const OrventusAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
        ChangeNotifierProvider(create: (context) => UsersProvider()),
        ChangeNotifierProvider(create: (context) => RidesProvider()), // <-- ADD THIS LINE
        ChangeNotifierProvider(create: (context) => ReviewsProvider()), // <-- ADD THIS LINE
        ChangeNotifierProvider(create: (context) => SettingsProvider()), // <-- ADD THIS LINE
        ChangeNotifierProvider(create: (context) => NotificationsProvider()), // <-- ADD THIS LINE

      ],
      child: MaterialApp(
        title: 'Orventus Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.grey[900]),
        initialRoute: '/auth_check',
        routes: {
          '/auth_check': (context) => const AuthCheckScreen(),
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const AdminDashboard(), // Your main screen is at the '/main' route
        },
      ),
    );
  }
}

// --- NEW WIDGETS ---

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});
  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }
  Future<void> _checkAuth() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (mounted) {
      if (token != null) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _authRepo = AuthRepository();
  bool _showOtpScreen = false;
  bool _isLoading = false;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  void _requestOtp() async {
    setState(() => _isLoading = true);
    try {
      await _authRepo.login(phone: _phoneController.text);
      setState(() => _showOtpScreen = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      await _authRepo.verifyOtp(phone: _phoneController.text, otp: _otpController.text);
      if (mounted) Navigator.of(context).pushReplacementNamed('/main');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 350,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showOtpScreen ? _buildOtpForm() : _buildLoginForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('loginForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Admin Login', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _isLoading ? null : _requestOtp, child: _isLoading ? const CircularProgressIndicator() : const Text('Send OTP')),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      key: const ValueKey('otpForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Verify OTP', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text('An OTP was sent to your backend console for phone: ${_phoneController.text}'),
        const SizedBox(height: 16),
        TextField(controller: _otpController, decoration: const InputDecoration(labelText: 'OTP')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _isLoading ? null : _verifyOtp, child: _isLoading ? const CircularProgressIndicator() : const Text('Verify & Log In')),
        TextButton(onPressed: () => setState(() => _showOtpScreen = false), child: const Text('Go Back')),
      ],
    );
  }
}

// --- YOUR ORIGINAL AdminDashboard WIDGET (UNCHANGED) ---
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const DashboardScreen(),
    const CustomersScreen(),
    const DriversScreen(),
    const RidesScreen(),
    const VehiclesScreen(),
    const PromoCodesScreen(),
    const DocumentsScreen(),
    const SettingsScreen(),
    const EarningsScreen(),
    const ManualBookingScreen(),
    const ReviewsScreen(),
    const NotificationsScreen(),
  ];

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200,
            color: const Color(0xFF2C3E50),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.local_taxi, color: Colors.white, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'ORVENTUS',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                      _buildNavItem(1, Icons.people, 'Customers'),
                      _buildNavItem(2, Icons.drive_eta, 'Drivers'),
                      _buildNavItem(3, Icons.list_alt, 'Rides'),
                      _buildNavItem(4, Icons.directions_car, 'Vehicles'),
                      _buildNavItem(5, Icons.local_offer, 'Promo Codes'),
                      _buildNavItem(6, Icons.description, 'Documents'),
                      _buildNavItem(7, Icons.settings, 'Settings'),
                      _buildNavItem(8, Icons.attach_money, 'Earnings'),
                      _buildNavItem(9, Icons.book_online, 'Manual Booking'),
                      _buildNavItem(10, Icons.star, 'Reviews'),
                      _buildNavItem(11, Icons.notifications, 'Notifications'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}