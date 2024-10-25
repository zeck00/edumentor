import 'package:edumentor/screens/questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/widgets/newswidget.dart';
import 'package:edumentor/asset-class/size_config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              // Top bar with logo and profile icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/logo.svg',
                        height: propHeight(55),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      // Handle profile tap
                    },
                    child: CircleAvatar(
                      radius: propWidth(22.5),
                      backgroundColor: AppColors.black,
                      child: SvgPicture.asset('assets/profile.svg'),
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
                height: propHeight(230),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    NewsCard(
                      imagePath: "assets/campus.png",
                      title: "AI-Powered Study...",
                    ),
                    NewsCard(
                      imagePath: 'assets/class.png',
                      title: 'Classrooms Evolved...',
                    ),
                    NewsCard(
                      imagePath: 'assets/power.png',
                      title: 'Classrooms Evolved...',
                    ),
                    NewsCard(
                      imagePath: 'assets/power.png',
                      title: 'Classrooms Evolved...',
                    ),
                  ],
                ),
              ),
              SizedBox(height: propHeight(15)),

              // EduMentor AI Section
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MCQQuizScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("EduMentor AI", style: FontStyles.hometitle),
                    SvgPicture.asset(
                      'assets/g-next.svg',
                      height: propHeight(30),
                    ),
                  ],
                ),
              ),
              SizedBox(height: propHeight(10)),

              // EduMentor AI Card - Navigating to QPage
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MCQQuizScreen()),
                  );
                },
                child: _customCard('assets/EduMentor.png'),
              ),
              SizedBox(height: propHeight(20)),

              // Course Material Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Course Material", style: FontStyles.hometitle),
                  SvgPicture.asset(
                    'assets/b-next.svg',
                    height: propHeight(30),
                  ),
                ],
              ),
              SizedBox(height: propHeight(10)),

              // Course Material Card
              _customCard('assets/CourseMaterial.png'),
              SizedBox(height: propHeight(30)),

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

  // Reusable method for custom cards (EduMentor AI & Course Material)
  Widget _customCard(String imagePath) {
    return Container(
      width: double.infinity,
      height: propHeight(135),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(propWidth(25)),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Reusable method for bottom buttons (Settings & About Us)
  Widget _bottomButton(String label) {
    return GestureDetector(
      onTap: () {
        // Handle button tap
      },
      child: Container(
        width: propWidth(175), // Set the width to 175 propWidth
        height: propHeight(55), // Set the height to 52 propHeight
        decoration: BoxDecoration(
          color: AppColors.gray, // Set the background color to gray
          borderRadius: BorderRadius.circular(propWidth(25)), // Rounded edges
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // Space text and icon
          children: [
            Text(
              label,
              style: FontStyles.button1
                  .copyWith(color: AppColors.black), // Button text style
            ),
            SvgPicture.asset(
              'assets/b-next.svg', // SVG icon as shown in the example
              height: propHeight(30), // Icon height adjusted to 30 propHeight
            ),
          ],
        ),
      ),
    );
  }
}
