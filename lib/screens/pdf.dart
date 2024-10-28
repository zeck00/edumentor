import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String pdfPath;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: Text(
          title,
          style: FontStyles.hometitle.copyWith(color: AppColors.white),
        ),
      ),
      body: SfPdfViewer.asset(
        enableTextSelection: true,
        pageSpacing: propHeight(10),
        pdfPath,
        key: Key(pdfPath),
      ),
    );
  }
}
