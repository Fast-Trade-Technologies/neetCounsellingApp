import 'dart:convert';

import 'package:dio/dio.dart';

import 'base_api.dart';

/// Services / subscription API for the Subscription page.
///
/// Endpoint: GET /pages/services
/// Full URL: http://neetcounseling.efasttrade.in/api/v1/pages/services
class ServicesApi {
  ServicesApi._();

  static final BaseAPI _api = BaseAPI();
  static const String _servicesPath = '/pages/services';

  /// Fetches course types and their pricing plans for subscription page.
  ///
  /// Returns (success, data, errorMessage).
  static Future<(bool success, ServicesResponse? data, String? errorMessage)>
      getServices() async {
    try {
      final Response? response = await _api.get(
        url: _servicesPath,
        showLoader: true,
      );

      if (response == null) {
        return (false, null, 'No response from server');
      }
      if (response.statusCode != 200) {
        return (false, null, 'Failed to load services');
      }

      final raw = response.data;

      // Handle both Map and String JSON (some Dio configs return raw String).
      Map<String, dynamic>? body;
      if (raw is Map) {
        body = Map<String, dynamic>.from(raw);
      } else if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map) {
            body = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {
          // fall through to error below
        }
      }

      if (body == null) {
        return (false, null, 'Invalid response');
      }

      final bool isSuccess =
          body['isSuccess'] == true || body['success'] == true;
      if (!isSuccess) {
        final msg = body['message']?.toString() ?? 'Failed to load services';
        return (false, null, msg);
      }

      final dataRaw = body['data'];
      if (dataRaw is! Map<String, dynamic>) {
        return (false, null, 'Invalid data payload');
      }

      final responseData = ServicesResponse.fromJson(dataRaw);
      return (true, responseData, null);
    } on DioException catch (e) {
      final msg = e.message ?? 'Something went wrong';
      return (false, null, msg);
    } catch (e) {
      return (false, null, e.toString());
    }
  }
}

class ServicesResponse {
  ServicesResponse({required this.courseTypes});

  final List<ServiceCourseType> courseTypes;

  factory ServicesResponse.fromJson(Map<String, dynamic> json) {
    final list = json['course_types'];
    if (list is! List) return ServicesResponse(courseTypes: const []);
    final types = <ServiceCourseType>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        types.add(ServiceCourseType.fromJson(item));
      }
    }
    return ServicesResponse(courseTypes: types);
  }
}

class ServiceCourseType {
  ServiceCourseType({
    required this.id,
    required this.name,
    required this.pricingPlans,
  });

  final String id;
  final String name;
  final List<ServicePricingPlan> pricingPlans;

  factory ServiceCourseType.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final list = json['pricing_plans'];

    final plans = <ServicePricingPlan>[];
    if (list is List) {
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          plans.add(ServicePricingPlan.fromJson(item));
        }
      }
    }

    return ServiceCourseType(
      id: id,
      name: name,
      pricingPlans: plans,
    );
  }
}

class ServicePricingPlan {
  ServicePricingPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.discount,
    required this.hasDiscount,
    required this.discountedPrice,
    required this.points,
  });

  final String id;
  final String name;
  final int price;
  final int discount;
  final bool hasDiscount;
  final int discountedPrice;
  final List<ServicePlanPoint> points;

  factory ServicePricingPlan.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString().trim() ?? '';
    final price = toInt(json['price']);
    final discount = toInt(json['discount']);
    final discountedPrice = toInt(json['discounted_price']);
    final hasDiscount = json['has_discount'] == true;

    final list = json['points'];
    final points = <ServicePlanPoint>[];
    if (list is List) {
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          points.add(ServicePlanPoint.fromJson(item));
        }
      }
    }

    return ServicePricingPlan(
      id: id,
      name: name,
      price: price,
      discount: discount,
      hasDiscount: hasDiscount,
      discountedPrice: discountedPrice,
      points: points,
    );
  }
}

class ServicePlanPoint {
  ServicePlanPoint({
    required this.text,
    required this.icon,
    required this.hasIcon,
  });

  final String text;
  final String icon;
  final bool hasIcon;

  factory ServicePlanPoint.fromJson(Map<String, dynamic> json) {
    return ServicePlanPoint(
      text: json['point']?.toString().trim() ?? '',
      icon: json['icon']?.toString() ?? '',
      hasIcon: json['has_icon'] == true,
    );
  }
}

