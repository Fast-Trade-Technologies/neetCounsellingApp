import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

import 'base_api.dart';

/// Represents a single filter option (state, counselling type, etc.) with id and display name.
/// Used by Helper APIs from Postman: /common/states, /common/counselling-types, etc.
class FilterItem {
  const FilterItem({required this.id, required this.name});

  final String id;
  final String name;

  @override
  String toString() => name;
}

/// Filter/helper APIs from NEET Counseling API Postman collection (Helper APIs only).
/// GET: pass all parameters in Params (query). Do not pass parameters in Header. POST: pass in Body.
/// Uses: GET /common/states, /common/counselling-types, /common/institute-types,
/// /common/quota, /common/branches. No /filter-options or /cities (not in collection).
class FiltersApi {
  static const String statesPath = '/common/states';
  static const String counsellingTypesPath = '/common/counselling-types';
  static const String instituteTypesPath = '/common/institute-types';
  static const String quotaPath = '/common/quota';
  static const String branchesPath = '/common/branches';
  static const String dependentFiltersPath = '/common/dependent-filters';

  static final BaseAPI _api = BaseAPI();

  /// GET /common/states. All params in query (nLoginUserIdNo in Params).
  /// Returns (success, list of FilterItem states, errorMessage).
  static Future<(bool success, List<FilterItem> states, String? errorMessage)> getStates({
    bool showLoader = false,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, <FilterItem>[], 'Please sign in to load filters');
    }
    try {
      final response = await _api.get(
        url: statesPath,
        queryParameters: {'nLoginUserIdNo': userId},
        showLoader: showLoader,
      );
      if (response == null || response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, <FilterItem>[], msg ?? 'Failed to load states');
      }
      final body = _parseBody(response.data);
      if (body == null) return (false, <FilterItem>[], 'Invalid response');
      final list = _parseFilterList(body['data'] ?? body['states'] ?? body);
      return (true, list, null);
    } on DioException catch (e) {
      final msg = e.response != null ? _messageFromResponse(e.response!) : e.message;
      return (false, <FilterItem>[], msg ?? 'Something went wrong');
    }
  }

  /// GET /common/counselling-types — optional for dropdowns.
  static Future<(bool success, List<FilterItem> list, String? errorMessage)> getCounsellingTypes({
    bool showLoader = false,
  }) async {
    return _getCommonList(counsellingTypesPath, showLoader: showLoader);
  }

  /// GET /common/institute-types?counselling_id= — optional for dropdowns.
  static Future<(bool success, List<FilterItem> list, String? errorMessage)> getInstituteTypes({
    required String counsellingId,
    bool showLoader = false,
  }) async {
    return _getCommonList(
      instituteTypesPath,
      queryParameters: {'counselling_id': counsellingId},
      showLoader: showLoader,
    );
  }

  /// GET /common/quota?counselling_id=&state_id=&institute_type_id=&course_type_id=
  /// All parameters are required by the API.
  static Future<(bool success, List<FilterItem> list, String? errorMessage)> getQuota({
    required String counsellingId,
    required String stateId,
    required String instituteTypeId,
    required String courseTypeId,
    bool showLoader = false,
  }) async {
    final q = <String, dynamic>{
      'counselling_id': counsellingId,
      'state_id': stateId,
      'institute_type_id': instituteTypeId,
      'course_type_id': courseTypeId,
    };
    return _getCommonList(quotaPath, queryParameters: q, showLoader: showLoader);
  }

  /// GET /common/branches?role_id=&course_id=
  static Future<(bool success, List<FilterItem> list, String? errorMessage)> getBranches({
    required String roleId,
    required String courseId,
    bool showLoader = false,
  }) async {
    return _getCommonList(
      branchesPath,
      queryParameters: {'role_id': roleId, 'course_id': courseId},
      showLoader: showLoader,
    );
  }

  /// GET /common/dependent-filters?quota_id=&nLoginUserIdNo=
  /// Returns category options for the given quota (used in Cut-off Allotments and Fees & Matrix).
  /// Response structure: { isSuccess: true, data: { categories: [{ id, name }], quotas: [], institute_types: [] } }
  static Future<(bool success, List<FilterItem> list, String? errorMessage)> getDependentFilters({
    required String quotaId,
    String? counsellingId,
    String? stateId,
    String? instituteTypeId,
    bool showLoader = false,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) return (false, <FilterItem>[], 'Please sign in');
    try {
      final query = <String, dynamic>{
        'nLoginUserIdNo': userId,
        'quota_id': quotaId,
        if (counsellingId != null && counsellingId.isNotEmpty) 'counselling_id': counsellingId,
        if (stateId != null && stateId.isNotEmpty) 'state_id': stateId,
        if (instituteTypeId != null && instituteTypeId.isNotEmpty) 'institute_type_id': instituteTypeId,
      };
      final response = await _api.get(
        url: dependentFiltersPath,
        queryParameters: query,
        showLoader: showLoader,
      );
      if (response == null || response.statusCode != 200) {
        return (false, <FilterItem>[], _messageFromResponse(response) ?? 'Request failed');
      }
      final body = _parseBody(response.data);
      if (body == null) return (false, <FilterItem>[], 'Invalid response');
      
      // Check isSuccess
      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      if (!isSuccess) {
        final message = body['message']?.toString();
        return (false, <FilterItem>[], message ?? 'Failed to load dependent filters');
      }
      
      // Parse categories from data.categories
      final data = body['data'];
      if (data is Map) {
        final categories = data['categories'];
        if (categories is List) {
          final list = _parseFilterList(categories);
          return (true, list, null);
        }
      }
      return (true, <FilterItem>[], null);
    } on DioException catch (e) {
      return (false, <FilterItem>[], e.message ?? 'Something went wrong');
    }
  }

  /// Cities API is not in the Postman collection. Returns empty list so UI does not break.
  static Future<(bool success, List<FilterItem> cities, String? errorMessage)> getCities({
    required String stateId,
    bool showLoader = false,
  }) async {
    return (true, <FilterItem>[], null);
  }

  static Future<(bool success, List<FilterItem> list, String? errorMessage)> _getCommonList(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool showLoader = false,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) return (false, <FilterItem>[], 'Please sign in');
    try {
      final query = <String, dynamic>{'nLoginUserIdNo': userId, ...?queryParameters};
      final response = await _api.get(
        url: path,
        queryParameters: query,
        showLoader: showLoader,
      );
      if (response == null || response.statusCode != 200) {
        return (false, <FilterItem>[], _messageFromResponse(response) ?? 'Request failed');
      }
      final body = _parseBody(response.data);
      if (body == null) return (false, <FilterItem>[], 'Invalid response');
      final list = _parseFilterList(body['data'] ?? body);
      return (true, list, null);
    } on DioException catch (e) {
      return (false, <FilterItem>[], e.message ?? 'Something went wrong');
    }
  }

  static List<FilterItem> _parseFilterList(dynamic raw) {
    if (raw is! List) return [];
    final list = <FilterItem>[];
    for (final e in raw) {
      if (e is Map) {
        final id = e['id']?.toString() ?? e['state_id']?.toString() ?? '';
        final name = e['name']?.toString() ?? e['state']?.toString() ?? '';
        if (id.isNotEmpty || name.isNotEmpty) list.add(FilterItem(id: id, name: name));
      }
    }
    return list;
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

  static String? _messageFromResponse(Response? response) {
    if (response == null) return null;
    try {
      final data = response.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
    } catch (_) {}
    return null;
  }
}
