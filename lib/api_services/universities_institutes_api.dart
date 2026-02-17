import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

import 'base_api.dart';

/// GET /universities-institutes from NEET Counseling API Postman collection.
/// Required params: nLoginUserIdNo, state_id_counselling, state_id
/// Optional: institute_type_id, university_id, page, per_page
class UniversitiesInstitutesApi {
  static const String path = '/universities-institutes';

  static final BaseAPI _api = BaseAPI();

  /// GET {{base_url}}/universities-institutes with query params.
  static Future<(bool success, Map<String, dynamic>? data, String? errorMessage)> getUniversitiesInstitutes({
    required String stateIdCounselling,
    required String stateId,
    String? instituteTypeId,
    String? universityId,
    int? page,
    int? perPage,
    bool showLoader = true,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to load universities institutes');
    }
    try {
      final query = <String, dynamic>{
        'nLoginUserIdNo': userId,
        'state_id_counselling': stateIdCounselling,
        'state_id': stateId,
      };
      if (instituteTypeId != null && instituteTypeId.isNotEmpty) query['institute_type_id'] = instituteTypeId;
      if (universityId != null && universityId.isNotEmpty) query['university_id'] = universityId;
      if (page != null) query['page'] = page.toString();
      if (perPage != null) query['per_page'] = perPage.toString();

      final response = await _api.get(
        url: path,
        queryParameters: query,
        showLoader: showLoader,
      );

      if (response == null) return (false, null, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, null, msg ?? 'Failed to load universities institutes');
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
      return (false, null, message ?? 'Failed to load universities institutes');
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
