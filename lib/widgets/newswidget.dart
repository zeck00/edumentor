import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';

class NewsCard extends StatelessWidget {
  final String imagePath;
  final String title;

  const NewsCard({
    required this.imagePath,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Container(
      width: propWidth(180),
      margin: EdgeInsets.only(right: propWidth(10)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(propWidth(25)),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(propWidth(25)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Title text with icon at the bottom-left
          Positioned(
            bottom: propHeight(10),
            left: propWidth(10),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/star.svg',
                  width: propWidth(15),
                  height: propHeight(15),
                ),
                SizedBox(width: propWidth(5)),
                Text(
                  title,
                  style: FontStyles.newstitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
