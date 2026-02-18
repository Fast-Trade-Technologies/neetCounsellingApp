import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

import 'base_api.dart';

class CompetitionStatisticsApi {
  static const String competitionPath = '/5-year-competition';

  static final BaseAPI _api = BaseAPI();

  /// GET {{base_url}}/5-year-competition
  /// Required params: user_stream, state_id, year
  /// Also includes nLoginUserIdNo
  static Future<(bool success, Map<String, dynamic>? data, String? errorMessage)> getCompetitionStatistics({
    required String stateId,
    required String year,
    bool showLoader = true,
    Map<String, dynamic>? extraQuery,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to load competition statistics');
    }
    final userStream = AppStorage.userStream ?? '1'; // Default to '1' if not set
    try {
      final query = <String, dynamic>{
        'nLoginUserIdNo': userId,
        'user_stream': userStream,
        'state_id': stateId,
        'year': year,
        ...?extraQuery,
      };
      final response = await _api.get(
        url: competitionPath,
        queryParameters: query,
        showLoader: showLoader,
      );
      if (response == null) return (false, null, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, null, msg ?? 'Failed to load competition statistics');
      }

      final body = _parseBody(response.data);
      if (body == null) return (false, null, 'Invalid response');

      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      final message = body['message']?.toString();
      final dataRaw = body['data'];

      if (isSuccess && dataRaw is Map) {
        return (true, Map<String, dynamic>.from(dataRaw), null);
      }
      return (false, null, message ?? 'Failed to load competition statistics');
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
