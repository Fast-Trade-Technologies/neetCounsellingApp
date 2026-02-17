import 'dart:convert';

import 'package:dio/dio.dart';

import 'base_api.dart';

/// Webinar API from NEET Counseling API Postman collection.
/// GET /webinars?id=webinarId
class WebinarApi {
  static const String webinarsPath = '/webinars';

  static final BaseAPI _api = BaseAPI();

  /// GET {{base_url}}/webinars?id=webinarId
  /// Returns (true, webinar data map, null) on success.
  static Future<(bool success, Map<String, dynamic>? data, String? errorMessage)> getWebinarDetails({
    required String webinarId,
    bool showLoader = true,
  }) async {
    try {
      final response = await _api.get(
        url: webinarsPath,
        queryParameters: {'id': webinarId},
        showLoader: showLoader,
      );

      if (response == null) return (false, null, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, null, msg ?? 'Failed to load webinar details');
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

      return (false, null, message ?? 'Failed to load webinar details');
    } on DioException catch (e) {
      final msg = e.response != null ? _messageFromResponse(e.response!) : e.message;
      return (false, null, msg ?? 'Something went wrong');
    } catch (e) {
      return (false, null, 'Error: ${e.toString()}');
    }
  }

  static String? _messageFromResponse(Response response) {
    try {
      final data = response.data;
      if (data is Map) {
        return data['message']?.toString() ?? data['error']?.toString();
      }
      if (data is String) {
        try {
          final json = jsonDecode(data);
          if (json is Map) {
            return json['message']?.toString() ?? json['error']?.toString();
          }
        } catch (_) {
          return data;
        }
      }
    } catch (_) {}
    return null;
  }

  static Map<String, dynamic>? _parseBody(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return null;
  }
}
