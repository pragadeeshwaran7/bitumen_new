//Store all base URLs and endpoint paths here

class ApiEndpoints {
  static const String baseUrl = 'https://trucker-backend.onrender.com/api';

  // ==================== AUTHENTICATION ENDPOINTS ====================
  
  // Auth (General)
  static const String authSendOtp = '$baseUrl/auth/send-otp';
  static const String authLogin = '$baseUrl/auth/login';
  static const String authLogout = '$baseUrl/auth/logout';
  static const String authRefreshToken = '$baseUrl/auth/refresh-token';
  
  // Customer Auth
  static const String customerSendOtp = '$baseUrl/customer/send-otp';
  static const String customerRegister = '$baseUrl/customer/register';
  static const String customerLogin = '$baseUrl/customer/login';
  static const String customerLogout = '$baseUrl/customer/logout';
  static const String customerRefreshToken = '$baseUrl/customer/refresh-token';
  
  // Supplier Auth
  static const String supplierSendOtp = '$baseUrl/supplier/send-otp';
  static const String supplierRegister = '$baseUrl/supplier/register';
  static const String supplierLogin = '$baseUrl/supplier/login';
  static const String supplierLogout = '$baseUrl/supplier/logout';
  static const String supplierRefreshToken = '$baseUrl/supplier/refresh-token';
  
  // Driver Auth
  static const String driverSendOtp = '$baseUrl/driver/send-otp';
  static const String driverRegister = '$baseUrl/driver/register';
  static const String driverLogin = '$baseUrl/driver/login';
  static const String driverLogout = '$baseUrl/driver/logout';
  static const String driverRefreshToken = '$baseUrl/driver/refresh-token';

  // ==================== CUSTOMER ENDPOINTS ====================
  
  // Customer Profile
  static const String customerProfile = '$baseUrl/customer/profile';
  static const String customerUpdateProfile = '$baseUrl/customer/profile';
  static const String customerDeleteProfile = '$baseUrl/customer/profile';
  
  // Customer Orders
  static const String customerOrders = '$baseUrl/customer/orders';
  static const String customerCreateOrder = '$baseUrl/customer/orders';
  static const String customerOrderById = '$baseUrl/customer/orders';
  static const String customerCancelOrder = '$baseUrl/customer/orders';
  static const String customerOrderHistory = '$baseUrl/customer/orders/history';
  
  // Customer Payments
  static const String customerPayments = '$baseUrl/customer/payments';
  static const String customerPaymentById = '$baseUrl/customer/payments';
  static const String customerPaymentHistory = '$baseUrl/customer/payments/history';
  
  // Customer Tracking
  static const String customerTrackOrder = '$baseUrl/customer/track';
  static const String customerOrderLocation = '$baseUrl/customer/track/location';

  // ==================== SUPPLIER ENDPOINTS ====================
  
  // Supplier Profile
  static const String supplierProfile = '$baseUrl/supplier/profile';
  static const String supplierUpdateProfile = '$baseUrl/supplier/profile';
  static const String supplierDeleteProfile = '$baseUrl/supplier/profile';
  
  // Supplier Orders
  static const String supplierOrders = '$baseUrl/supplier/orders';
  static const String supplierOrderById = '$baseUrl/supplier/orders';
  static const String supplierAcceptOrder = '$baseUrl/supplier/orders';
  static const String supplierRejectOrder = '$baseUrl/supplier/orders';
  static const String supplierOrderHistory = '$baseUrl/supplier/orders/history';
  
  // Supplier Tankers
  static const String supplierTankers = '$baseUrl/supplier/tankers';
  static const String supplierAddTanker = '$baseUrl/supplier/tankers';
  static const String supplierTankerById = '$baseUrl/supplier/tankers';
  static const String supplierUpdateTanker = '$baseUrl/supplier/tankers';
  static const String supplierDeleteTanker = '$baseUrl/supplier/tankers';
  
  // Supplier Drivers
  static const String supplierDrivers = '$baseUrl/supplier/drivers';
  static const String supplierAddDriver = '$baseUrl/supplier/drivers';
  static const String supplierDriverById = '$baseUrl/supplier/drivers';
  static const String supplierUpdateDriver = '$baseUrl/supplier/drivers';
  static const String supplierDeleteDriver = '$baseUrl/supplier/drivers';
  
  // Supplier Payments
  static const String supplierPayments = '$baseUrl/supplier/payments';
  static const String supplierPaymentById = '$baseUrl/supplier/payments';
  static const String supplierPaymentHistory = '$baseUrl/supplier/payments/history';
  
  // Supplier Analytics
  static const String supplierAnalytics = '$baseUrl/supplier/analytics';
  static const String supplierEarnings = '$baseUrl/supplier/earnings';
  static const String supplierReports = '$baseUrl/supplier/reports';

  // ==================== DRIVER ENDPOINTS ====================
  
  // Driver Profile
  static const String driverProfile = '$baseUrl/driver/profile';
  static const String driverUpdateProfile = '$baseUrl/driver/profile';
  static const String driverDeleteProfile = '$baseUrl/driver/profile';
  
  // Driver Orders
  static const String driverOrders = '$baseUrl/driver/orders';
  static const String driverOrderById = '$baseUrl/driver/orders';
  static const String driverAcceptOrder = '$baseUrl/driver/orders';
  static const String driverRejectOrder = '$baseUrl/driver/orders';
  static const String driverStartTrip = '$baseUrl/driver/orders';
  static const String driverCompleteTrip = '$baseUrl/driver/orders';
  static const String driverOrderHistory = '$baseUrl/driver/orders/history';
  
  // Driver Location & Tracking
  static const String driverLocation = '$baseUrl/driver/location';
  static const String driverUpdateLocation = '$baseUrl/driver/location';
  static const String driverLocationHistory = '$baseUrl/driver/location/history';
  
  // Driver Tankers
  static const String driverTankers = '$baseUrl/driver/tankers';
  static const String driverTankerById = '$baseUrl/driver/tankers';
  
  // Driver Earnings
  static const String driverEarnings = '$baseUrl/driver/earnings';
  static const String driverEarningsHistory = '$baseUrl/driver/earnings/history';

  // ==================== GENERAL ENDPOINTS ====================
  
  // Orders (General)
  static const String orders = '$baseUrl/orders';
  static const String createOrder = '$baseUrl/orders';
  static const String orderById = '$baseUrl/orders';
  static const String updateOrderStatus = '$baseUrl/orders';
  static const String assignDriver = '$baseUrl/orders';
  static const String assignTanker = '$baseUrl/orders';
  static const String orderHistory = '$baseUrl/orders/history';
  static const String orderStatistics = '$baseUrl/orders/statistics';
  
  // Tankers (General)
  static const String tankers = '$baseUrl/tankers';
  static const String addTanker = '$baseUrl/tankers';
  static const String tankerById = '$baseUrl/tankers';
  static const String updateTanker = '$baseUrl/tankers';
  static const String deleteTanker = '$baseUrl/tankers';
  static const String availableTankers = '$baseUrl/tankers/available';
  static const String tankerLocationHistory = '$baseUrl/tankers/location-history';
  
  // Drivers (General)
  static const String drivers = '$baseUrl/drivers';
  static const String addDriver = '$baseUrl/drivers';
  static const String driverById = '$baseUrl/drivers';
  static const String updateDriver = '$baseUrl/drivers';
  static const String deleteDriver = '$baseUrl/drivers';
  static const String availableDrivers = '$baseUrl/drivers/available';
  
  // Tracking (General)
  static const String trackOrder = '$baseUrl/track';
  static const String trackByTrackingNumber = '$baseUrl/track/by-tracking-number';
  static const String updateLocation = '$baseUrl/track/location';
  static const String orderLocationHistory = '$baseUrl/track/location-history';
  static const String currentOrderLocation = '$baseUrl/track/current-location';
  static const String nearbyDrivers = '$baseUrl/track/nearby-drivers';
  static const String nearbyTankers = '$baseUrl/track/nearby-tankers';
  
  // Payments (General)
  static const String payments = '$baseUrl/payments';
  static const String createPayment = '$baseUrl/payments';
  static const String paymentById = '$baseUrl/payments';
  static const String paymentHistory = '$baseUrl/payments/history';
  static const String paymentStatistics = '$baseUrl/payments/statistics';
  
  // Razorpay Integration
  static const String razorpayCreateOrder = '$baseUrl/payments/razorpay/create-order';
  static const String razorpayVerifyPayment = '$baseUrl/payments/razorpay/verify';
  static const String razorpayRefund = '$baseUrl/payments/razorpay/refund';
  
  // Notifications
  static const String notifications = '$baseUrl/notifications';
  static const String markNotificationRead = '$baseUrl/notifications';
  static const String notificationSettings = '$baseUrl/notifications/settings';
  
  // Support & Help
  static const String supportTickets = '$baseUrl/support/tickets';
  static const String createSupportTicket = '$baseUrl/support/tickets';
  static const String supportTicketById = '$baseUrl/support/tickets';
  static const String faq = '$baseUrl/support/faq';
  
  // Analytics & Reports
  static const String analytics = '$baseUrl/analytics';
  static const String reports = '$baseUrl/reports';
  static const String dashboard = '$baseUrl/dashboard';
  
  // File Upload
  static const String uploadFile = '$baseUrl/upload';
  static const String uploadMultipleFiles = '$baseUrl/upload/multiple';
  
  // Settings
  static const String appSettings = '$baseUrl/settings';
  static const String updateSettings = '$baseUrl/settings';
  
  // Health Check
  static const String healthCheck = '$baseUrl/health';
  static const String version = '$baseUrl/version';
}
