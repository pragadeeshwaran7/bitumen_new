import 'base_api_service.dart';

class DriverService extends BaseApiService {
  
  // Get driver profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await get('/driver/profile');
    return response.data;
  }

  // Update driver profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? licenseNumber,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (licenseNumber != null) data['license_number'] = licenseNumber;

    final response = await put('/driver/profile', data: data);
    return response.data;
  }

  // Get driver orders
  Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await get(
      '/driver/orders',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get specific order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    final response = await get('/driver/orders/$orderId');
    return response.data;
  }

  // Accept order
  Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    final response = await put('/driver/orders/$orderId/accept');
    return response.data;
  }

  // Reject order
  Future<Map<String, dynamic>> rejectOrder(String orderId, {String? reason}) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;

    final response = await put('/driver/orders/$orderId/reject', data: data);
    return response.data;
  }

  // Start trip
  Future<Map<String, dynamic>> startTrip(String orderId) async {
    final response = await put('/driver/orders/$orderId/start');
    return response.data;
  }

  // Complete trip
  Future<Map<String, dynamic>> completeTrip(String orderId) async {
    final response = await put('/driver/orders/$orderId/complete');
    return response.data;
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
    String? notes,
    double? latitude,
    double? longitude,
  }) async {
    final data = <String, dynamic>{'status': status};
    if (notes != null) data['notes'] = notes;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;

    final response = await put('/driver/orders/$orderId/status', data: data);
    return response.data;
  }

  // Update location
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    String? orderId,
  }) async {
    final data = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
    if (orderId != null) data['order_id'] = orderId;

    final response = await post('/driver/location', data: data);
    return response.data;
  }

  // Get assigned tankers
  Future<List<Map<String, dynamic>>> getTankers() async {
    final response = await get('/driver/tankers');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get tanker details
  Future<Map<String, dynamic>> getTankerDetails(String tankerId) async {
    final response = await get('/driver/tankers/$tankerId');
    return response.data;
  }

  // Update tanker status
  Future<Map<String, dynamic>> updateTankerStatus({
    required String tankerId,
    required String status,
    String? notes,
  }) async {
    final data = {'status': status};
    if (notes != null) data['notes'] = notes;

    final response = await put('/driver/tankers/$tankerId/status', data: data);
    return response.data;
  }

  // Get earnings
  Future<Map<String, dynamic>> getEarnings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    final response = await get(
      '/driver/earnings',
      queryParameters: queryParams,
    );
    return response.data;
  }

  // Get payment history
  Future<List<Map<String, dynamic>>> getPayments({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await get(
      '/driver/payments',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Get payment details
  Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    final response = await get('/driver/payments/$paymentId');
    return response.data;
  }

  // Report issue
  Future<Map<String, dynamic>> reportIssue({
    required String orderId,
    required String issueType,
    required String description,
    String? priority,
  }) async {
    final data = {
      'order_id': orderId,
      'issue_type': issueType,
      'description': description,
    };
    if (priority != null) data['priority'] = priority;

    final response = await post('/driver/issues', data: data);
    return response.data;
  }

  // Get notifications
  Future<List<Map<String, dynamic>>> getNotifications({
    bool? unreadOnly,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (unreadOnly != null) queryParams['unread_only'] = unreadOnly;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await get(
      '/driver/notifications',
      queryParameters: queryParams,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await put('/driver/notifications/$notificationId/read');
  }
}
