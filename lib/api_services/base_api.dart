import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';

import 'package:neetcounsellingapp/app/core/snackbar/app_snackbar.dart';
import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

/// Base URL from NEET Counseling API Postman collection (variable base_url).
// const String baseUrl = 'https://neetcounseling.efasttrade.in/api/v1';
const String baseUrl = 'https://neetcounseling.com/api/v1';

/// Minimal overlay/loader and snackbar used by [BaseAPI]. Uses GetStorage via [AppStorage].
class _BaseOverlays {
  void showLoader({bool? showLoader = true}) {
    if (showLoader != true) return;
    if (getx.Get.isDialogOpen == true) return;
    getx.Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void dismissOverlay({bool? showLoader = true}) {
    if (showLoader != true) return;
    if (getx.Get.isDialogOpen == true) getx.Get.back();
  }

  void showSnackBar({required String message}) {
    AppSnackbar.info('', message);
  }

  void warningShowSnackBar({required String message}) {
    AppSnackbar.warning('', message);
  }

  void updateProgress(int progress) {
    // Optional: could update a progress dialog if needed
  }
}

/// NEET API uses nLoginUserIdNo (userId from verify-otp) for auth. Login token is only for verify-otp/resend-otp.
Map<String, String> _authHeaders() {
  final userId = AppStorage.userId;
  if (userId == null || userId.isEmpty) return {};
  return {'nLoginUserIdNo': userId};
}

class BaseAPI {
  late Dio _dio;
  static final BaseAPI _singleton = BaseAPI._internal();
  factory BaseAPI() {
    return _singleton;
  }

  BaseAPI._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 59),
        receiveTimeout: const Duration(seconds: 59),
        sendTimeout: const Duration(minutes: 1),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    if (!kReleaseMode) {
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
    }
    _dio.interceptors.add(
        LogInterceptor(responseBody: true, request: true, requestBody: true));
  }

  /// GET Method.
  /// Convention: pass all parameters in [queryParameters] (Params). Do not pass request
  /// parameters in headers — use headers only for header values (e.g. Accept, Content-Type).
  /// POST: pass parameters in body.
  Future<Response?> get(
      {required String url,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
      bool? showLoader,
      bool focusOff = true}) async {
    if (await checkInternetConnection()) {
      try {
        _BaseOverlays().showLoader(showLoader: showLoader ?? true);
        focusOff
            ? FocusScope.of(getx.Get.context!).requestFocus(FocusNode())
            : null;
        final requestHeaders = <String, dynamic>{...?headers};
        final response = await _dio.get(
          url,
          options: Options(headers: requestHeaders),
          queryParameters: queryParameters,
        );
        _BaseOverlays().dismissOverlay(showLoader: showLoader ?? true);
        return response;
      } on DioException catch (e) {
        _BaseOverlays().dismissOverlay(showLoader: showLoader ?? true);
        _handleError(e);
        rethrow;
      }
    } else {
      _BaseOverlays().showSnackBar(message: "No internet connection");
      return null;
    }
  }

  /// POST Method.
  /// Convention: pass all request parameters in [data] (request body), not in query.
  /// Set [skipAuth] to true for public endpoints (login, verify-otp, resend-otp, register).
  /// Authenticated APIs use nLoginUserIdNo header (userId from verify-otp).
  Future<Response?> post(
      {required String url,
      dynamic data,
      Map<String, dynamic>? headers,
      bool? showLoader,
      bool skipAuth = false}) async {
    if (await checkInternetConnection()) {
      try {
        _BaseOverlays().showLoader(showLoader: showLoader);
        FocusScope.of(getx.Get.context!).requestFocus(FocusNode());
        final Map<String, dynamic> requestHeaders = Map<String, dynamic>.from(headers ?? {});
        if (!skipAuth) requestHeaders.addAll(_authHeaders());
        final response = await _dio.post(url,
            data: data,
            options: Options(headers: requestHeaders));
        _BaseOverlays().dismissOverlay(showLoader: showLoader);
        return response;
      } on DioException catch (e) {
        _BaseOverlays().dismissOverlay(showLoader: showLoader);
        _handleError(e);
        rethrow;
      }
    } else {
      _BaseOverlays().showSnackBar(message: "No internet connection");
      return null;
    }
  }

  /// PATCH Method. Convention: pass parameters in body [data].
  Future<Response?> patch(
      {required String url,
      dynamic data,
      Map<String, dynamic>? headers,
      bool? concatUserId}) async {
    if (await checkInternetConnection()) {
      try {
        _BaseOverlays().showLoader();
        FocusScope.of(getx.Get.context!).requestFocus(FocusNode());
        final String userId = AppStorage.userId ?? "";
        final Map<String, dynamic> requestHeaders = Map<String, dynamic>.from(headers ?? {});
        requestHeaders.addAll(_authHeaders());
        final response = await _dio.patch(
            url + ((concatUserId ?? false) ? userId : ""),
            data: data,
            options: Options(headers: requestHeaders));
        _BaseOverlays().dismissOverlay();
        return response;
      } on DioException catch (e) {
        _BaseOverlays().dismissOverlay();
        _handleError(e);
        rethrow;
      }
    } else {
      _BaseOverlays().showSnackBar(message: "No internet connection");
      return null;
    }
  }

  /// PUT Method. Convention: pass parameters in body [data].
  Future<Response?> put(
      {required String url,
      dynamic data,
      Map<String, dynamic>? headers}) async {
    if (await checkInternetConnection()) {
      try {
        _BaseOverlays().showLoader();
        FocusScope.of(getx.Get.context!).requestFocus(FocusNode());
        final Map<String, dynamic> requestHeaders = Map<String, dynamic>.from(headers ?? {});
        requestHeaders.addAll(_authHeaders());
        final response = await _dio.put(url,
            data: data,
            options: Options(headers: requestHeaders));
        _BaseOverlays().dismissOverlay();
        return response;
      } on DioException catch (e) {
        _BaseOverlays().dismissOverlay();
        _handleError(e);
        rethrow;
      }
    } else {
      _BaseOverlays().showSnackBar(message: "No internet connection");
      return null;
    }
  }

  /// Delete Method
  Future<Response?> delete(
      {required String url,
      Map<String, dynamic>? headers,
      dynamic data}) async {
    FocusScope.of(getx.Get.context!).requestFocus(FocusNode());
    if (await checkInternetConnection()) {
      try {
        _BaseOverlays().showLoader();
        final Map<String, dynamic> requestHeaders = Map<String, dynamic>.from(headers ?? {});
        requestHeaders.addAll(_authHeaders());
        final response = await _dio.delete(url,
            data: data,
            options: Options(headers: requestHeaders));
        _BaseOverlays().dismissOverlay();
        return response;
      } on DioException catch (e) {
        _BaseOverlays().dismissOverlay();
        _handleError(e);
        rethrow;
      }
    } else {
      _BaseOverlays().showSnackBar(message: "No internet connection");
      return null;
    }
  }

  /// Download Method

  // Future<Response?> download(String? url, {String ext = ".pdf", Map<String, dynamic>? headers}) async {
  //   log('download url: $url');
  //   if (url == 'null' || (url ?? "").isEmpty) {
  //     _BaseOverlays().showSnackBar(message: "Url not found");
  //     return null;
  //   }

  //   try {
  //     // App-specific storage directory
  //     Directory directory = await getApplicationDocumentsDirectory();
  //     String fileName = url!.split('/').last;
  //     int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  //     String savePath = '${directory.path}/$timestamp-$fileName$ext';

  //     log("Saving to: $savePath");

  //     final Map<String, dynamic> requestHeaders = Map<String, dynamic>.from(headers ?? {});
  //     requestHeaders.addAll(_authHeaders());
  //     _BaseOverlays().showLoader();

  //     final response = await Dio().download(
  //       url,
  //       savePath,
  //       options: Options(headers: requestHeaders),
  //       onReceiveProgress: (received, total) {
  //         int progress = ((received / total) * 100).toInt();
  //         _BaseOverlays().updateProgress(progress);
  //       },
  //     );

  //     _BaseOverlays().dismissOverlay();
  //     // **File Open**

  //     await OpenFilex.open(savePath);
  //     return response;
  //   } catch (e) {
  //     log("Error: $e");
  //     _BaseOverlays().dismissOverlay();
  //     _BaseOverlays().showSnackBar(message: e.toString());
  //     throw e.toString();
  //   }
  // }



  int _secondsRemaining = 20;

  /// Check Internet Connection
  Future<bool> checkInternetConnection() async {
    Timer timer;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
       _secondsRemaining--;
      log('internet timer: $_secondsRemaining');
      if (_secondsRemaining == 10) {
        timer.cancel();
        _BaseOverlays().warningShowSnackBar(message: "Slow internet connection detected");
      }
      if (_secondsRemaining < 0) {
        timer.cancel();
      }
    });
    List<ConnectivityResult> ? connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false; // No network at all
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      timer.cancel();
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      timer.cancel();
      return false;
    }
  }

  void _handleError(DioException e) {
    log('errorType--->>>${e.type} --||---errorMessage-->>${e.message}');
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      _BaseOverlays().showSnackBar(message: e.message ?? '');
    } else if (e.type == DioExceptionType.badResponse) {
      try {
        _BaseOverlays().showSnackBar(message: (e.response?.data['message']));
      } catch (error) {
        _BaseOverlays().showSnackBar(message: e.message ?? '');
      }
    } else if (e.type == DioExceptionType.cancel) {
    } else if (e.type == DioExceptionType.connectionError) {
      _BaseOverlays().showSnackBar(message: e.message ?? '');
    } else {
      log('Unknown Error: ${e.message}');
      _BaseOverlays()
          .showSnackBar(message: e.message ?? 'Something Went Wrong!!!');
    }
  }
}

class NoInternetException implements Exception {
  final String message;
  NoInternetException([this.message = "No internet connection"]);

  @override
  String toString() => message;
}
