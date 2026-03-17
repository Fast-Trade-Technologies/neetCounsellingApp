import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
      appBar: AppBar(
        title: Text(title?.isNotEmpty == true ? title! : 'Sample Document'),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}

