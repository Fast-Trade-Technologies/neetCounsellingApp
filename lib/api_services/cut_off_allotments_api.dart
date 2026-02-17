import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

import 'base_api.dart';

/// GET /cut-off-allotments from NEET Counseling API Postman collection.
/// All params in query: nLoginUserIdNo, state_id_counselling, state_id, year;
/// optional: institute_type_id, course_id, quota_id, sm_category_id.
class CutOffAllotmentsApi {
  static const String path = '/cut-off-allotments';

  static final BaseAPI _api = BaseAPI();

  /// GET {{base_url}}/cut-off-allotments with query params (no header params).
  static Future<(bool success, Map<String, dynamic>? data, String? errorMessage)> getCutOffAllotments({
    required String stateId,
    required String year,
    String? instituteTypeId,
    String? courseId,
    String? quotaId,
    String? smCategoryId,
    bool showLoader = true,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to load cut-off allotments');
    }
    try {
      final query = <String, dynamic>{
        'nLoginUserIdNo': userId,
        'state_id': stateId,
        'year': year,
      };
      if (instituteTypeId != null && instituteTypeId.isNotEmpty) query['institute_type_id'] = instituteTypeId;
      if (courseId != null && courseId.isNotEmpty) query['course_id'] = courseId;
      if (quotaId != null && quotaId.isNotEmpty) query['quota_id'] = quotaId;
      if (smCategoryId != null && smCategoryId.isNotEmpty) query['sm_category_id'] = smCategoryId;

      final response = await _api.get(
        url: path,
        queryParameters: query,
        showLoader: showLoader,
      );

      if (response == null) return (false, null, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, null, msg ?? 'Failed to load cut-off allotments');
      }

      final body = _parseBody(response.data);
      if (body == null) return (false, null, 'Invalid response');

      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      final message = body['message']?.toString();

      if (isSuccess) {
        final dataRaw = body['data'];
        if (dataRaw is Map) return (true, Map<String, dynamic>.from(dataRaw), null);
        return (true, <String, dynamic>{}, null);
      }
      return (false, null, message ?? 'Failed to load cut-off allotments');
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
