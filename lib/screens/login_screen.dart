// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../data/repository/auth_repository.dart';

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
      if (mounted) Navigator.of(context).pushReplacementNamed('/main'); // Go to main app screen
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