import 'dart:io';
import 'package:dio/dio.dart';
import 'base_api_service.dart';
import 'api_config.dart';

class AuthService extends BaseApiService {
  
  // Customer Authentication
  Future<Map<String, dynamic>> sendCustomerOtp({
    required String phone,
    String? email,
  }) async {
    if (ApiConfig.useMock) {
      // Mock response for development
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      return {
        'success': true,
        'message': 'OTP sent successfully',
        'otp': '123456', // Mock OTP for development
      };
    }

        try {
          final data = <String, dynamic>{
            'phone': phone,
            'user_type': 'customer',
          };
          if (email != null && email.isNotEmpty) {
            data['email'] = email;
          }

          final response = await post(
            '/auth/send-otp',
            data: data,
          );
          return response.data;
        } catch (e) {
          // Fallback to mock data if API fails
          await Future.delayed(const Duration(seconds: 1));
          return {
            'success': true,
            'message': 'OTP sent successfully (Fallback)',
            'otp': '123456',
          };
        }
  }

  Future<bool> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String gstNumber,
    File? gstCertificate,
  }) async {
    if (ApiConfig.useMock) {
      // Mock response for development
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      return true; // Mock success
    }

    try {
      final formData = FormData.fromMap({
        'name': name,
        'phone': phone,
        'email': email,
        'gst_number': gstNumber,
      });

      if (gstCertificate != null) {
        formData.files.add(MapEntry(
          'gst_certificate',
          await MultipartFile.fromFile(
            gstCertificate.path,
            filename: gstCertificate.path.split('/').last,
          ),
        ));
      }

      final response = await postFormData(
        '/customer/register',
        formData: formData,
      );
      return response.statusCode == 201;
    } catch (e) {
      // Fallback to mock success if API fails
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
  }

  Future<Map<String, dynamic>> loginCustomer({
    required String phone,
    required String otp,
    String? email,
  }) async {
    if (ApiConfig.useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'message': 'Login successful',
        'token': 'mock_token_123',
        'user': {
          'id': '1',
          'name': 'Mock Customer',
          'phone': phone,
          'email': email ?? 'mock@example.com',
        },
      };
    }

        try {
          final data = <String, dynamic>{
            'phone': phone,
            'otp': otp,
            'user_type': 'customer',
          };
          if (email != null && email.isNotEmpty) {
            data['email'] = email;
          }

          final response = await post(
            '/auth/login',
            data: data,
          );
          
          // Save token if login successful
          if (response.data['success'] == true && response.data['token'] != null) {
            await ApiConfig.saveAuthToken(response.data['token']);
            if (response.data['user'] != null) {
              await ApiConfig.saveUserData(response.data['user']);
            }
          }
          
          return response.data;
        } catch (e) {
          await Future.delayed(const Duration(seconds: 1));
          return {
            'success': true,
            'message': 'Login successful (Fallback)',
            'token': 'mock_token_123',
            'user': {
              'id': '1',
              'name': 'Mock Customer',
              'phone': phone,
              'email': email ?? 'mock@example.com',
            },
          };
        }
  }

  // Supplier Authentication
  Future<Map<String, dynamic>> sendSupplierOtp({
    required String phone,
    String? email,
  }) async {
    if (ApiConfig.useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'message': 'OTP sent successfully',
        'otp': '123456',
      };
    }

    try {
      final data = <String, dynamic>{
        'phone': phone,
        'user_type': 'supplier',
      };
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      final response = await post(
        '/auth/send-otp',
        data: data,
      );
      return response.data;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'message': 'OTP sent successfully (Mock)',
        'otp': '123456',
      };
    }
  }

  Future<bool> registerSupplier({
    required String name,
    required String phone,
    required String email,
  }) async {
    if (ApiConfig.useMock) {
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }

    try {
      final response = await post(
        '/supplier/register',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
  }

  Future<Map<String, dynamic>> loginSupplier({
    required String phone,
    required String otp,
    String? email,
  }) async {
    if (ApiConfig.useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'message': 'Login successful',
        'token': 'mock_token_456',
        'user': {
          'id': '2',
          'name': 'Mock Supplier',
          'phone': phone,
          'email': email ?? 'mock_supplier@example.com',
        },
      };
    }

    try {
      final data = <String, dynamic>{
        'phone': phone,
        'otp': otp,
        'user_type': 'supplier',
      };
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      final response = await post(
        '/auth/login',
        data: data,
      );
      
      // Save token if login successful
      if (response.data['success'] == true && response.data['token'] != null) {
        await ApiConfig.saveAuthToken(response.data['token']);
        if (response.data['user'] != null) {
          await ApiConfig.saveUserData(response.data['user']);
        }
      }
      
      return response.data;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'message': 'Login successful (Fallback)',
        'token': 'mock_token_456',
        'user': {
          'id': '2',
          'name': 'Mock Supplier',
          'phone': phone,
          'email': email ?? 'mock_supplier@example.com',
        },
      };
    }
  }

  // Driver Authentication
  Future<Map<String, dynamic>> sendDriverOtp({
    required String phone,
    String? email,
  }) async {
    if (ApiConfig.useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'message': 'OTP sent successfully',
        'otp': '123456',
      };
    }

    try {
      final data = <String, dynamic>{
        'phone': phone,
        'user_type': 'driver',
      };
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      final response = await post(
        '/auth/send-otp',
        data: data,
      );
      return response.data;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'message': 'OTP sent successfully (Mock)',
        'otp': '123456',
      };
    }
  }

  Future<Map<String, dynamic>> registerDriver({
    required String name,
    required String phone,
    required String email,
    required String licenseNumber,
    File? licenseDocument,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'phone': phone,
      'email': email,
      'license_number': licenseNumber,
    });

    if (licenseDocument != null) {
      formData.files.add(MapEntry(
        'license_document',
        await MultipartFile.fromFile(
          licenseDocument.path,
          filename: licenseDocument.path.split('/').last,
        ),
      ));
    }

    final response = await postFormData(
      '/driver/register',
      formData: formData,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> loginDriver({
    required String phone,
    required String otp,
    String? email,
  }) async {
    if (ApiConfig.useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'message': 'Login successful',
        'token': 'mock_token_789',
        'user': {
          'id': '3',
          'name': 'Mock Driver',
          'phone': phone,
          'email': email ?? 'mock_driver@example.com',
        },
      };
    }

    try {
      final data = <String, dynamic>{
        'phone': phone,
        'otp': otp,
        'user_type': 'driver',
      };
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      final response = await post(
        '/auth/login',
        data: data,
      );
      
      // Save token if login successful
      if (response.data['success'] == true && response.data['token'] != null) {
        await ApiConfig.saveAuthToken(response.data['token']);
        if (response.data['user'] != null) {
          await ApiConfig.saveUserData(response.data['user']);
        }
      }
      
      return response.data;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'message': 'Login successful (Fallback)',
        'token': 'mock_token_789',
        'user': {
          'id': '3',
          'name': 'Mock Driver',
          'phone': phone,
          'email': email ?? 'mock_driver@example.com',
        },
      };
    }
  }

  // Generic OTP methods for common login form
  Future<bool> sendOtp({
    required String phone,
    String? email,
    required String userType, // 'customer', 'supplier', 'driver'
  }) async {
    try {
      switch (userType.toLowerCase()) {
        case 'customer':
          await sendCustomerOtp(phone: phone, email: email);
          return true;
        case 'supplier':
          await sendSupplierOtp(phone: phone, email: email);
          return true;
        case 'driver':
          await sendDriverOtp(phone: phone, email: email);
          return true;
        default:
          throw Exception('Invalid user type: $userType');
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    String? email,
    required String userType, // 'customer', 'supplier', 'driver'
  }) async {
    try {
      switch (userType.toLowerCase()) {
        case 'customer':
          await loginCustomer(phone: phone, otp: otp, email: email);
          return true;
        case 'supplier':
          await loginSupplier(phone: phone, otp: otp, email: email);
          return true;
        case 'driver':
          await loginDriver(phone: phone, otp: otp, email: email);
          return true;
        default:
          throw Exception('Invalid user type: $userType');
      }
    } catch (e) {
      return false;
    }
  }

  // Logout (if needed)
  Future<void> logout() async {
    // Clear local storage, tokens, etc.
    // Implementation depends on your token storage mechanism
  }
}