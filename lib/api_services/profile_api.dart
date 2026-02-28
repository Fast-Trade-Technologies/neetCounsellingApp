import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

import 'base_api.dart';

/// Profile APIs from NEET Counseling API Postman collection.
/// GET /user/profile, PUT /user/profile (Update user Profile) with nLoginUserIdNo in query.
class ProfileApi {
  static const String profilePath = '/user/profile';

  static final BaseAPI _api = BaseAPI();

  /// GET {{base_url}}/user/profile with nLoginUserIdNo in query params.
  /// Returns (true, profile data map, null) on success.
  static Future<(bool success, Map<String, dynamic>? data, String? errorMessage)> getProfile({
    bool showLoader = true,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to load profile');
    }
    try {
      final response = await _api.get(
        url: profilePath,
        queryParameters: {'nLoginUserIdNo': userId},
        showLoader: showLoader,
      );

      if (response == null) return (false, null, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, null, msg ?? 'Failed to load profile');
      }

      final body = _parseBody(response.data);
      if (body == null) return (false, null, 'Invalid response');

      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      final message = body['message']?.toString();

      if (isSuccess) {
        final dataRaw = body['data'];
        if (dataRaw is Map) {
          return (true, Map<String, dynamic>.from(dataRaw), null);
        }
        return (true, <String, dynamic>{}, null);
      }
      return (false, null, message ?? 'Failed to load profile');
    } on DioException catch (e) {
      final msg = e.response != null ? _messageFromResponse(e.response!) : e.message;
      return (false, null, msg ?? 'Something went wrong');
    }
  }

  /// PUT {{base_url}}/user/profile?nLoginUserIdNo=<userId> (Update user Profile).
  /// Body: { user_id, first_name, last_name, mobile, email?, image_base64? } — Content-Type: application/json.
  /// [imageBase64] optional; when provided (e.g. from picked image), sent as "image_base64" in body (data URL or raw base64).
  static Future<(bool success, Map<String, dynamic>? data, String? errorMessage)> updateProfile({
    required String firstName,
    required String lastName,
    required String mobile,
    String? email,
    String? imageBase64,
    bool showLoader = true,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to update profile');
    }
    try {
      final body = <String, dynamic>{
        'nLoginUserIdNo': userId,
        'first_name': firstName,
        'last_name': lastName,
        'mobile': mobile,
      };
      if (email != null && email.trim().isNotEmpty) {
        body['email'] = email.trim();
      }
      if (imageBase64 != null && imageBase64.trim().isNotEmpty) {
        body['image_base64'] = imageBase64.trim();
      }
      

      final urlWithQuery = '/user/profile-update?nLoginUserIdNo=$userId';
      final response = await _api.put(
        url: urlWithQuery,
        data: body,
        headers: {'Content-Type': 'application/json'},
      );

      if (response == null) return (false, null, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, null, msg ?? 'Failed to update profile');
      }

      final responseBody = _parseBody(response.data);
      if (responseBody == null) return (false, null, 'Invalid response');

      final isSuccess = responseBody['isSuccess'] == true || responseBody['success'] == true;
      final message = responseBody['message']?.toString();

      if (isSuccess) {
        final dataRaw = responseBody['data'];
        if (dataRaw is Map) {
          return (true, Map<String, dynamic>.from(dataRaw), null);
        }
        return (true, <String, dynamic>{}, null);
      }
      return (false, null, message ?? 'Failed to update profile');
    } on DioException catch (e) {
      final msg = e.response != null ? _messageFromResponse(e.response!) : e.message;
      return (false, null, msg ?? 'Something went wrong');
    }
  }

  static Map<String, dynamic>? _parseBody(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String? _messageFromResponse(Response response) {
    try {
      final data = response.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
    } catch (_) {}
    return null;
  }
}
