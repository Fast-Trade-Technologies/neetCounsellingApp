import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:get/get.dart';
import 'package:neetcounsellingapp/app/core/widgets/detail_app_bar.dart';

class PdfWebViewPage extends StatelessWidget {
  const PdfWebViewPage({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailAppBar(
        title: title?.isNotEmpty == true ? title! : 'Sample Document',
        // subtitle: 'Neet Counselling / Post-Exam / Checklist & Sample Views',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      // appBar: AppBar(
      //   title: Text(title?.isNotEmpty == true ? title! : 'Sample Document'),
      // ),
      body: SfPdfViewer.network(url),
    );
  }
}

