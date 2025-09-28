import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:io';

class TestRazorpayScreen extends StatefulWidget {
  const TestRazorpayScreen({super.key});

  @override
  State<TestRazorpayScreen> createState() => _TestRazorpayScreenState();
}

class _TestRazorpayScreenState extends State<TestRazorpayScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Success: ${response.paymentId}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Error: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _testRazorpay() async {
    try {
      print('=== TESTING RAZORPAY DIRECTLY ===');
      print('Platform: ${Platform.operatingSystem}');
      
      if (Platform.isWindows) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Razorpay is not supported on Windows desktop. Please test on Android/iOS.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      var options = {
        'key': 'rzp_test_ZXpLTWIn4Ro6NC',
        'amount': 10000, // ₹100 in paise
        'currency': 'INR',
        'name': 'Trucker App Test',
        'description': 'Test Payment',
        'order_id': 'test_order_${DateTime.now().millisecondsSinceEpoch}',
        'timeout': 300,
        'prefill': {
          'contact': '+91 9876543210',
          'email': 'test@example.com',
          'name': 'Test User',
        },
        'theme': {
          'color': '#FF5722'
        },
        'retry': {
          'enabled': true,
          'max_count': 3
        }
      };

      print('Opening Razorpay with options: $options');
      _razorpay.open(options);
      print('Razorpay.open() called successfully');
      
    } catch (e) {
      print('Error in test Razorpay: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Razorpay'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.payment,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Test Razorpay Integration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Platform: ${Platform.operatingSystem}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _testRazorpay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.payment),
              label: const Text('Test Razorpay Payment'),
            ),
            const SizedBox(height: 20),
            const Text(
              'This will open Razorpay gateway directly',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

