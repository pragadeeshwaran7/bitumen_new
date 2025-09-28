import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:io';

class TestPaymentScreen extends StatefulWidget {
  const TestPaymentScreen({super.key});

  @override
  State<TestPaymentScreen> createState() => _TestPaymentScreenState();
}

class _TestPaymentScreenState extends State<TestPaymentScreen> {
  bool _isLoading = false;
  String _paymentStatus = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isLoading = false;
      _paymentStatus = 'Payment successful!';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment successful! Payment ID: ${response.paymentId}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _paymentStatus = 'Payment failed';
      _errorMessage = response.message ?? 'Payment failed';
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _paymentStatus = 'External wallet selected: ${response.walletName}';
    });
  }

  Future<void> _testPayment() async {
    print('=== TESTING RAZORPAY PAYMENT ===');
    print('Platform: ${Platform.operatingSystem}');
    
    setState(() {
      _isLoading = true;
      _paymentStatus = 'Opening Razorpay...';
      _errorMessage = '';
    });

    try {
      // Check if running on Windows (desktop)
      if (Platform.isWindows) {
        print('Running on Windows - Razorpay may not work on desktop');
        setState(() {
          _isLoading = false;
          _paymentStatus = 'Payment gateway not supported on Windows desktop';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Razorpay payment gateway is not supported on Windows desktop. Please test on Android/iOS device.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        
        // Simulate payment success for testing
        await Future.delayed(const Duration(seconds: 2));
        _handlePaymentSuccess(PaymentSuccessResponse(
          'mock_payment_${DateTime.now().millisecondsSinceEpoch}',
          'mock_order_${DateTime.now().millisecondsSinceEpoch}',
          'mock_signature',
          {},
        ));
        return;
      }

      // Create Razorpay instance
      final razorpay = Razorpay();
      
      // Create checkout options
      var options = {
        'key': 'rzp_test_ZXpLTWIn4Ro6NC', // Your Razorpay Key ID
        'amount': 10000, // ₹100 in paise
        'currency': 'INR',
        'name': 'Trucker App',
        'description': 'Test Payment',
        'order_id': 'test_order_${DateTime.now().millisecondsSinceEpoch}',
        'timeout': 300, // 5 minutes
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

      print('About to open Razorpay with options: $options');
      
      // Attach event listeners
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      
      razorpay.open(options);
      print('Razorpay.open() called successfully');
      
      setState(() {
        _paymentStatus = 'Payment gateway opened';
      });
      
    } catch (e) {
      print('Error in test payment: $e');
      setState(() {
        _isLoading = false;
        _paymentStatus = 'Failed to open payment gateway';
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Razorpay Payment'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Payment Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Payment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount:'),
                        Text(
                          '₹100.00',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Currency:'),
                        Text('INR', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Method:'),
                        Text('Razorpay', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Test Payment Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.payment),
                label: Text(
                  _isLoading ? 'Opening Razorpay...' : 'Test Razorpay Payment',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Payment Status
            if (_paymentStatus.isNotEmpty) ...[
              Card(
                color: _errorMessage.isNotEmpty ? Colors.red.shade50 : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _errorMessage.isNotEmpty ? Icons.error : Icons.info,
                        color: _errorMessage.isNotEmpty ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _paymentStatus,
                          style: TextStyle(
                            color: _errorMessage.isNotEmpty ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Click "Test Razorpay Payment" button\n'
                      '2. Razorpay payment gateway should open\n'
                      '3. Use test card: 4111 1111 1111 1111\n'
                      '4. Use any future expiry date\n'
                      '5. Use any CVV\n'
                      '6. Complete the payment',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

