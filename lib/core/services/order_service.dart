import 'base_api_service.dart';
import '../constants/api_endpoints.dart';
import 'api_config.dart';

class OrderService extends BaseApiService {
  
  // Get all orders (admin/super user)
  Future<List<Map<String, dynamic>>> getAllOrders({
    String? status,
    String? customerId,
    String? supplierId,
    String? driverId,
    int? page,
    int? limit,
  }) async {
    if (ApiConfig.useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'id': '1',
          'order_id': 'TR123456789',
          'customer_id': '1',
          'supplier_id': '2',
          'driver_id': '3',
          'tanker_id': '4',
          'status': 'in_transit',
          'pickup_location': 'Mumbai, Maharashtra',
          'delivery_location': 'Pune, Maharashtra',
          'goods_type': 'VG30 Bitumen',
          'quantity': 2.0,
          'unit': 'tons',
          'amount': 12500.0,
          'currency': 'INR',
          'pickup_date': '2025-02-15T10:00:00Z',
          'delivery_date': '2025-02-15T18:00:00Z',
          'created_at': '2025-02-15T08:00:00Z',
          'updated_at': '2025-02-15T10:00:00Z',
        },
        {
          'id': '2',
          'order_id': 'TR987654321',
          'customer_id': '1',
          'supplier_id': '2',
          'driver_id': null,
          'tanker_id': '5',
          'status': 'pending',
          'pickup_location': 'Delhi, Delhi',
          'delivery_location': 'Jaipur, Rajasthan',
          'goods_type': 'PMB Bitumen',
          'quantity': 3.0,
          'unit': 'tons',
          'amount': 18750.0,
          'currency': 'INR',
          'pickup_date': '2025-02-18T14:30:00Z',
          'delivery_date': '2025-02-18T22:30:00Z',
          'created_at': '2025-02-18T12:30:00Z',
          'updated_at': '2025-02-18T14:30:00Z',
        },
      ];
    }

    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (customerId != null) queryParams['customer_id'] = customerId;
      if (supplierId != null) queryParams['supplier_id'] = supplierId;
      if (driverId != null) queryParams['driver_id'] = driverId;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await get(
        ApiEndpoints.orders,
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      // Fallback to mock data
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'id': '1',
          'order_id': 'TR123456789',
          'status': 'in_transit',
          'pickup_location': 'Mumbai, Maharashtra',
          'delivery_location': 'Pune, Maharashtra',
          'amount': 12500.0,
          'created_at': '2025-02-15T10:00:00Z',
        },
      ];
    }
  }

  // Get order by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await get('/orders/$orderId');
    return response.data;
  }

  // Create new order
  Future<Map<String, dynamic>> createOrder({
    required String customerId,
    required String pickupLocation,
    required String deliveryLocation,
    required String goodsType,
    required double quantity,
    required double amount,
    String? tankerId,
    String? driverId,
    String? notes,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = {
      'customer_id': customerId,
      'pickup_location': pickupLocation,
      'delivery_location': deliveryLocation,
      'goods_type': goodsType,
      'quantity': quantity,
      'amount': amount,
    };

    if (tankerId != null) data['tanker_id'] = tankerId;
    if (driverId != null) data['driver_id'] = driverId;
    if (notes != null) data['notes'] = notes;
    if (pickupDate != null) data['pickup_date'] = pickupDate.toIso8601String();
    if (deliveryDate != null) data['delivery_date'] = deliveryDate.toIso8601String();
    if (additionalData != null) data.addAll(Map<String, Object>.from(additionalData));

    final response = await post('/orders', data: data);
    return response.data;
  }

  // Update order
  Future<Map<String, dynamic>> updateOrder({
    required String orderId,
    String? status,
    String? pickupLocation,
    String? deliveryLocation,
    String? goodsType,
    double? quantity,
    double? amount,
    String? tankerId,
    String? driverId,
    String? notes,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = <String, dynamic>{};
    if (status != null) data['status'] = status;
    if (pickupLocation != null) data['pickup_location'] = pickupLocation;
    if (deliveryLocation != null) data['delivery_location'] = deliveryLocation;
    if (goodsType != null) data['goods_type'] = goodsType;
    if (quantity != null) data['quantity'] = quantity;
    if (amount != null) data['amount'] = amount;
    if (tankerId != null) data['tanker_id'] = tankerId;
    if (driverId != null) data['driver_id'] = driverId;
    if (notes != null) data['notes'] = notes;
    if (pickupDate != null) data['pickup_date'] = pickupDate.toIso8601String();
    if (deliveryDate != null) data['delivery_date'] = deliveryDate.toIso8601String();
    if (additionalData != null) data.addAll(Map<String, Object>.from(additionalData));

    final response = await put('/orders/$orderId', data: data);
    return response.data;
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
    String? notes,
    String? updatedBy,
  }) async {
    final data = {'status': status};
    if (notes != null) data['notes'] = notes;
    if (updatedBy != null) data['updated_by'] = updatedBy;

    final response = await put('/orders/$orderId/status', data: data);
    return response.data;
  }

  // Assign driver to order
  Future<Map<String, dynamic>> assignDriver({
    required String orderId,
    required String driverId,
  }) async {
    final response = await put(
      '/orders/$orderId/assign-driver',
      data: {'driver_id': driverId},
    );
    return response.data;
  }

  // Assign tanker to order
  Future<Map<String, dynamic>> assignTanker({
    required String orderId,
    required String tankerId,
  }) async {
    final response = await put(
      '/orders/$orderId/assign-tanker',
      data: {'tanker_id': tankerId},
    );
    return response.data;
  }

  // Cancel order
  Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    required String reason,
    String? cancelledBy,
  }) async {
    final data = {'reason': reason};
    if (cancelledBy != null) data['cancelled_by'] = cancelledBy;

    final response = await put('/orders/$orderId/cancel', data: data);
    return response.data;
  }

  // Get order history/timeline
  Future<List<Map<String, dynamic>>> getOrderHistory(String orderId) async {
    final response = await get('/orders/$orderId/history');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get orders by status
  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
    final response = await get('/orders/status/$status');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get orders by date range
  Future<List<Map<String, dynamic>>> getOrdersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? status,
  }) async {
    final queryParams = {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
    if (status != null) queryParams['status'] = status;

    final response = await get(
      '/orders/date-range',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    String? supplierId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
    if (customerId != null) queryParams['customer_id'] = customerId;
    if (supplierId != null) queryParams['supplier_id'] = supplierId;

    final response = await get(
      '/orders/statistics',
      queryParameters: queryParams,
    );
    return response.data;
  }

  // Search orders
  Future<List<Map<String, dynamic>>> searchOrders({
    String? query,
    String? status,
    String? customerId,
    String? supplierId,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (query != null) queryParams['q'] = query;
    if (status != null) queryParams['status'] = status;
    if (customerId != null) queryParams['customer_id'] = customerId;
    if (supplierId != null) queryParams['supplier_id'] = supplierId;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await get(
      '/orders/search',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}
