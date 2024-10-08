import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:flutter/material.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: propWidth(16),
            vertical: propHeight(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with logo and profile icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/logo.svg',
                        height: propHeight(40),
                      ),
                      Text(
                        "EduMentor",
                        style: FontStyles.hometitleg, // Green home title
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      // Handle profile tap
                    },
                    child: Icon(
                      Icons.account_circle_outlined,
                      color: MyColors.black,
                      size: propWidth(30),
                    ),
                  ),
                ],
              ),
              SizedBox(height: propHeight(20)),

              // Latest News Section
              Text(
                "Latest News",
                style: FontStyles.hometitle, // Default title style
              ),
              SizedBox(height: propHeight(10)),

              // News Grid
              SizedBox(
                height: propHeight(150), // Height for the news cards
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _newsCard('assets/campus.png', 'AI-Powered Study...'),
                    _newsCard('assets/class.png', 'Classrooms Evolved...'),
                    _newsCard('assets/power.png', 'Classrooms Evolved...'),
                  ],
                ),
              ),
              SizedBox(height: propHeight(20)),

              // EduMentor AI Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("EduMentor AI", style: FontStyles.hometitle),
                  Icon(
                    Icons.arrow_forward,
                    color: MyColors.green,
                    size: propWidth(20),
                  ),
                ],
              ),
              SizedBox(height: propHeight(10)),

              // EduMentor AI Card
              _customCard('assets/images/ai_image.png'),
              SizedBox(height: propHeight(20)),

              // Course Material Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Course Material", style: FontStyles.hometitle),
                  Icon(
                    Icons.arrow_forward,
                    color: MyColors.black,
                    size: propWidth(20),
                  ),
                ],
              ),
              SizedBox(height: propHeight(10)),

              // Course Material Card
              _customCard('assets/CourseMaterial.png'),
              SizedBox(height: propHeight(20)),

              // Bottom Buttons (Settings & About Us)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bottomButton("Settings"),
                  _bottomButton("About Us"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable method for news card
  Widget _newsCard(String imagePath, String title) {
    return Container(
      width: propWidth(120),
      margin: EdgeInsets.only(right: propWidth(10)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(propWidth(10)),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.all(propWidth(8)),
          color: Colors.black.withOpacity(0.5),
          child: Text(
            title,
            style: FontStyles.newstitle, // News title style
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Reusable method for custom cards (EduMentor AI & Course Material)
  Widget _customCard(String imagePath) {
    return Container(
      width: double.infinity,
      height: propHeight(100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(propWidth(20)),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Reusable method for bottom buttons (Settings & About Us)
  Widget _bottomButton(String label) {
    return ElevatedButton.icon(
      onPressed: () {
        // Handle button tap
      },
      icon:
          Icon(Icons.arrow_forward, size: propWidth(20), color: MyColors.black),
      label: Text(
        label,
        style: FontStyles.button1, // Button style
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.white,
        shadowColor: MyColors.black.withAlpha(50),
        elevation: 5,
        padding: EdgeInsets.symmetric(
          horizontal: propWidth(30),
          vertical: propHeight(15),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(propWidth(20)),
        ),
      ),
    );
  }
}
