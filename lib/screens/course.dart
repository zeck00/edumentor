import 'package:edumentor/screens/pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';

class CourseMaterialPage extends StatelessWidget {
  final List<String> _courseMaterials =
      List.generate(15, (index) => 'Lecture ${index + 1} Material');

  CourseMaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: propWidth(16),
            vertical: propHeight(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with back button and title
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: RotatedBox(
                      quarterTurns: 2,
                      child: SvgPicture.asset(
                        'assets/b-next.svg',
                        height: propHeight(30),
                      ),
                    ),
                  ),
                  SizedBox(width: propWidth(70)),
                  Text(
                    "Course Material",
                    style: FontStyles.hometitle,
                  ),
                ],
              ),
              SizedBox(height: propHeight(20)),

              // List of course materials
              Expanded(
                child: ListView.builder(
                  itemCount: _courseMaterials.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to PDF viewer with the selected material
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreen(
                              title: _courseMaterials[index],
                              pdfPath: 'assets/PDFs/Lec (${index + 1}).pdf',
                            ),
                          ),
                        );
                      },
                      child: _courseMaterialCard(_courseMaterials[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _courseMaterialCard(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: propHeight(15)),
      padding: EdgeInsets.symmetric(
        horizontal: propWidth(20),
        vertical: propHeight(15),
      ),
      decoration: BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.circular(propWidth(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: propHeight(10),
            offset: Offset(propWidth(0), propHeight(0)),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: FontStyles.hometitle.copyWith(
              fontSize: propText(18),
              color: AppColors.black,
            ),
          ),
          SvgPicture.asset(
            'assets/g-next.svg',
            height: propHeight(25),
          ),
        ],
      ),
    );
  }
}
