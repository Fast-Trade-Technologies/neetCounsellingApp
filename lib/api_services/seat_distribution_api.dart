import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

import 'base_api.dart';

class SeatDistributionApi {
  static const String seatDistributionPath = '/seat-distribution';

  static final BaseAPI _api = BaseAPI();

  /// GET {{base_url}}/seat-distribution. All params in query (no userId in header).
  /// Query: nLoginUserIdNo, state_id, year, state_id_counselling (optional).
  static Future<(bool success, Map<String, dynamic>? data, String? errorMessage)> getSeatDistribution({
    bool showLoader = true,
    Map<String, dynamic>? extraQuery,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to load seat distribution');
    }
    try {
      final query = <String, dynamic>{
        'nLoginUserIdNo': userId,
        'state_id': extraQuery?['state_id'] ?? '1',
        'year': extraQuery?['year'] ?? '2025',
      };
      if (extraQuery != null && extraQuery['state_id_counselling'] != null) {
        query['state_id_counselling'] = extraQuery['state_id_counselling'];
      }
      if (extraQuery != null && extraQuery['course_id'] != null && (extraQuery['course_id'] as String).isNotEmpty) {
        query['course_id'] = extraQuery['course_id'];
      }
      final response = await _api.get(
        url: seatDistributionPath,
        queryParameters: query,
        showLoader: showLoader,
      );
      if (response == null) return (false, null, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, null, msg ?? 'Failed to load seat distribution');
      }

      final body = _parseBody(response.data);
      if (body == null) return (false, null, 'Invalid response');

      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      final message = body['message']?.toString();
      final dataRaw = body['data'];

      if (isSuccess && dataRaw is Map) {
        return (true, Map<String, dynamic>.from(dataRaw), null);
      }
      return (false, null, message ?? 'Failed to load seat distribution');
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

