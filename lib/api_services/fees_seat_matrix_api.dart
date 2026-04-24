import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

import 'base_api.dart';

/// GET /fees-seat-matrix from NEET Counseling API Postman collection.
/// Required: nLoginUserIdNo, state_id_counselling, state_id, year.
/// Optional: course_id, clinical_type_id, page (default 1), per_page (default 20, max 100).
class FeesSeatMatrixApi {
  static const String path = '/fees-seat-matrix';
  static const int maxPerPage = 100;

  static final BaseAPI _api = BaseAPI();

  /// GET {{base_url}}/fees-seat-matrix
  /// Query: nLoginUserIdNo, state_id_counselling, state_id, year, [course_id], [clinical_type_id], [page], [per_page]
  static Future<(bool success, Map<String, dynamic>? data, String? errorMessage)> getFeesSeatMatrix({
    required String stateIdCounselling,
    required String stateId,
    required String year,
    String? instituteTypeId,
    String? courseId,
    String? quotaId,
    String? smCategoryId,
    String? clinicalTypeId,
    int? page,
    int? perPage,
    bool showLoader = true,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to load fees seat matrix');
    }
    try {
      final query = <String, dynamic>{
        'nLoginUserIdNo': userId,
        'state_id_counselling': stateIdCounselling,
        'state_id': stateId,
        'year': year,
      };
      if (courseId != null && courseId.isNotEmpty) query['course_id'] = courseId;
      if (instituteTypeId != null && instituteTypeId.isNotEmpty) query['institute_type_id'] = instituteTypeId;
      if (quotaId != null && quotaId.isNotEmpty) query['quota_id'] = quotaId;
      if (smCategoryId != null && smCategoryId.isNotEmpty) query['sm_category_id'] = smCategoryId;
      if (clinicalTypeId != null && clinicalTypeId.isNotEmpty) query['clinical_type_id'] = clinicalTypeId;
      if (page != null && page > 0) query['page'] = page.toString();
      if (perPage != null && perPage > 0) query['per_page'] = (perPage > maxPerPage ? maxPerPage : perPage).toString();

      final response = await _api.get(
        url: path,
        queryParameters: query,
        showLoader: showLoader,
      );

      if (response == null) return (false, null, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, null, msg ?? 'Failed to load fees seat matrix');
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
      return (false, null, message ?? 'Failed to load fees seat matrix');
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
