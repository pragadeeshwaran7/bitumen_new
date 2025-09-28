import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:io';
import '../core/services/customer_service.dart';
import '../core/services/razorpay_service.dart';

class CustomerPaymentsPage extends StatefulWidget {
  const CustomerPaymentsPage({super.key});

  @override
  State<CustomerPaymentsPage> createState() => _CustomerPaymentsPageState();
}

class _CustomerPaymentsPageState extends State<CustomerPaymentsPage> {
  String selectedFilter = 'All';
  int selectedIndex = 2;
  bool _isLoading = true;
  List<Map<String, dynamic>> _payments = [];
  String _errorMessage = '';

  final CustomerService _customerService = CustomerService();
  final RazorpayService _razorpayService = RazorpayService();

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final payments = await _customerService.getPayments();
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load payments: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get unpaidPayments {
    return _payments.where((p) => 
      p['status']?.toLowerCase() == 'pending' || 
      p['status']?.toLowerCase() == 'failed' ||
      p['status']?.toLowerCase() == 'unpaid'
    ).toList();
  }

  List<Map<String, dynamic>> get filteredPayments {
    if (selectedFilter == 'All') return _payments;
    return _payments.where((p) => p['status']?.toLowerCase() == selectedFilter.toLowerCase()).toList();
  }

  Future<void> _makePayment(Map<String, dynamic> order) async {
    try {
      print('=== MAKING PAYMENT WITH RAZORPAY SERVICE ===');
      print('Platform: ${Platform.operatingSystem}');
      print('Order: $order');

      // Initialize Razorpay service with callbacks
      _razorpayService.initialize(
        onPaymentSuccess: (PaymentSuccessResponse response) async {
          print('Payment successful: ${response.paymentId}');
          
          try {
            // Update order status after payment
            await _customerService.updateOrderStatusAfterPayment(
              orderId: order['order_id'] ?? order['id'] ?? '',
              paymentId: response.paymentId ?? '',
              status: 'Paid',
            );
            print('Order status updated to Paid');
          } catch (e) {
            print('Failed to update order status: $e');
            // Continue with success flow even if status update fails
          }
          
          // Refresh payments
          _loadPayments();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment completed successfully! Payment ID: ${response.paymentId}'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onPaymentError: (PaymentFailureResponse response) {
          print('Payment failed: ${response.message}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onExternalWallet: (ExternalWalletResponse response) {
          print('External wallet selected: ${response.walletName}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('External wallet selected: ${response.walletName}'),
              backgroundColor: Colors.blue,
            ),
          );
        },
      );

      // Open payment gateway using service
      await _razorpayService.openPaymentGateway(
        orderId: order['order_id'] ?? order['id'] ?? 'order_${DateTime.now().millisecondsSinceEpoch}',
        amount: order['amount'] ?? 0.0,
        currency: order['currency'] ?? 'INR',
        customerName: order['customer_name'] ?? 'Customer',
        customerEmail: order['customer_email'] ?? 'customer@example.com',
        customerPhone: order['customer_phone'] ?? '+91 9876543210',
        description: 'Payment for Order ${order['order_id'] ?? order['id']}',
      );
      
      print('Razorpay payment gateway opened successfully');
      
    } catch (e) {
      print('Error in payment process: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void onBottomBarTap(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/customer-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/customer-orders');
        break;
      case 2:
        break; // Stay on Payments
      case 3:
        Navigator.pushReplacementNamed(context, '/customer-track');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/customer-account');
        break;
    }
  }

  void _showUnpaidOrdersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text('Unpaid Orders (${unpaidPayments.length})'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: unpaidPayments.length,
              itemBuilder: (context, index) {
                final payment = unpaidPayments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${payment['order_id'] ?? payment['id'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                payment['status']?.toUpperCase() ?? 'PENDING',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Amount: ₹${payment['amount'] ?? '0'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${payment['created_at']?.toString().split('T')[0] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _makePayment(payment);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.payment, size: 16),
                            label: const Text('Pay Now'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget buildFilterButton(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (label == 'Completed') const Icon(Icons.check_circle_outline, size: 16),
            if (label == 'Pending') const Icon(Icons.schedule, size: 16),
            if (label == 'All') const Icon(Icons.receipt_long, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentCard(Map<String, dynamic> payment) {
    final status = payment['status'] ?? 'pending';
    final amount = payment['amount'] ?? 0.0;
    final orderId = payment['order_id'] ?? payment['id'] ?? '';
    
    Color statusColor = status.toLowerCase() == 'pending'
        ? Colors.orange
        : status.toLowerCase() == 'completed'
            ? Colors.green
            : status.toLowerCase() == 'failed'
                ? Colors.red
                : Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    payment['payment_method'] ?? 'Razorpay',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            payment['created_at'] ?? payment['date'] ?? 'N/A',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            "Order: $orderId",
            style: const TextStyle(fontSize: 13),
          ),
          if (payment['payment_id'] != null)
            Text(
              "Payment ID: ${payment['payment_id']}",
              style: const TextStyle(fontSize: 13),
            ),
          const SizedBox(height: 12),
          
          // Payment Action Button
          if (status.toLowerCase() == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _makePayment(payment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.payment, size: 18),
                label: const Text('Pay Now'),
              ),
            )
          else if (status.toLowerCase() == 'failed')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _makePayment(payment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry Payment'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No payments found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPayments,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading payments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPayments,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        title: const Text("Payments", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: _loadPayments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          
          // Unpaid Orders Section
          if (unpaidPayments.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Unpaid Orders (${unpaidPayments.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You have ${unpaidPayments.length} unpaid order${unpaidPayments.length > 1 ? 's' : ''} that require immediate payment.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Show unpaid orders in a dialog or navigate to them
                        _showUnpaidOrdersDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.payment, size: 18),
                      label: Text('Pay ${unpaidPayments.length} Order${unpaidPayments.length > 1 ? 's' : ''}'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Filter Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['All', 'Completed', 'Pending', 'Failed']
                .map(buildFilterButton)
                .toList(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.red))
                : _errorMessage.isNotEmpty
                    ? _buildErrorState()
                    : filteredPayments.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadPayments,
                            color: Colors.red,
                            child: ListView.builder(
                              itemCount: filteredPayments.length,
                              itemBuilder: (context, index) =>
                                  buildPaymentCard(filteredPayments[index]),
                            ),
                          ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onBottomBarTap,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment), label: 'Payments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.track_changes), label: 'Track Order'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }
}
