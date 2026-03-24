import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:neetcounsellingapp/app/core/storage/app_storage_keys.dart';
import 'package:neetcounsellingapp/app/core/widgets/detail_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CollegeSeatsWebViewPage extends StatefulWidget {
 CollegeSeatsWebViewPage({super.key});

  String first_name = GetStorage().read(AppStorageKeys.userFirstName) ?? '';
  String last_name = GetStorage().read(AppStorageKeys.userLastName) ?? '';
  String stream = GetStorage().read(AppStorageKeys.userStream) ?? '';
  String userPhone = GetStorage().read(AppStorageKeys.userPhone) ?? '';



 late String pageUrl = Uri.https(
  'neetcounseling.efasttrade.in',
  '/student_admin/index-second.php',
  {
    'first_name': first_name,
    'last_name': last_name,
    'stream': stream,
    'mobile': userPhone,
  },
).toString();
  @override
  State<CollegeSeatsWebViewPage> createState() => _CollegeSeatsWebViewPageState();
}

class _CollegeSeatsWebViewPageState extends State<CollegeSeatsWebViewPage> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('pageUrl: ${widget.pageUrl}');
    _webViewController = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onPageStarted: (_) {
        if (mounted) setState(() => _isLoading = true);
      },
      onPageFinished: (_) {
        if (mounted) setState(() => _isLoading = false);
      },
    ),
  )
  ..loadRequest(Uri.parse(widget.pageUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DetailAppBar(
        title: 'Analysis College & Seats',
        subtitle: 'College & Seats',
        onBack: () => Get.back(),
        hideFilter: true,
        // onFilter: () => _openFilterSheet(context),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

