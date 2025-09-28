import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';

class DriverLogin extends StatefulWidget {
  const DriverLogin({super.key});

  @override
  State<DriverLogin> createState() => _DriverLoginState();
}

class _DriverLoginState extends State<DriverLogin> {
  String loginMethod = 'phone';
  bool isLoading = false;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final AuthService _authService = AuthService();

  Future<void> sendLoginOtp() async {
    if (isLoading) return;
    
    setState(() => isLoading = true);
    
    try {
      final phone = loginMethod == 'phone' ? phoneController.text : '';
      final email = loginMethod == 'email' ? emailController.text : '';
      
      await _authService.sendDriverOtp(
        phone: phone,
        email: email.isNotEmpty ? email : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Login via'),
            Row(
              children: [
                Radio(
                  value: 'phone',
                  groupValue: loginMethod,
                  onChanged: (value) => setState(() => loginMethod = value!),
                ),
                const Text('Phone'),
                Radio(
                  value: 'email',
                  groupValue: loginMethod,
                  onChanged: (value) => setState(() => loginMethod = value!),
                ),
                const Text('Email'),
              ],
            ),
            if (loginMethod == 'phone')
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
            if (loginMethod == 'email')
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendLoginOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Send OTP'),
            ),
            const SizedBox(height: 30),
            const Text(
              'By continuing, you agree to our Terms & Conditions and Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
