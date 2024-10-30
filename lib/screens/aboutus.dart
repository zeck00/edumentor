import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
                  SizedBox(width: propWidth(110)),
                  Text(
                    "About Us",
                    style: FontStyles.hometitle,
                  ),
                ],
              ),
              SizedBox(height: propHeight(20)),

              // About Us content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: propWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Welcome To Edu',
                                  style: FontStyles.hometitle),
                              TextSpan(
                                  text: 'Mentor', style: FontStyles.hometitleg),
                            ],
                          ),
                        ),
                        SizedBox(height: propHeight(10)),
                        Text(
                          "EduMentor is an AI-powered learning assistant created by Ziad, developed under the supervision of the College of Health Sciences and the College of Computing and Informatics at the University of Sharjah (UOS). 🎓",
                          style: FontStyles.sub,
                        ),
                        SizedBox(height: propHeight(20)),
                        Text(
                          "🚀 Key Features",
                          style: FontStyles.hometitle.copyWith(
                            fontSize: propText(20),
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: propHeight(10)),
                        _buildFeature("AI-Generated Questions",
                            "Say goodbye to static study materials! EduMentor uses AI to generate relevant and dynamic questions based on your course content."),
                        SizedBox(height: propHeight(10)),
                        _buildFeature("Performance Tracking",
                            "With real-time analysis, EduMentor tracks your progress and provides feedback on your strengths and areas that need improvement."),
                        SizedBox(height: propHeight(10)),
                        _buildFeature("Personalized Study Experience",
                            "Whether you're revising for exams or keeping up with your weekly lessons, EduMentor tailors questions and feedback based on your performance."),
                        SizedBox(height: propHeight(10)),
                        _buildFeature("Easy-to-Use Interface",
                            "Designed with simplicity and efficiency in mind, EduMentor offers an intuitive interface that makes learning a breeze."),
                        SizedBox(height: propHeight(20)),
                        Text(
                          "📱 Coming Soon to App Stores!",
                          style: FontStyles.hometitle.copyWith(
                            fontSize: propText(20),
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: propHeight(10)),
                        Text(
                          "EduMentor will soon be available for download on both iOS and Android. Stay tuned for the official release on the App Store and Google Play! Follow along with the project for updates and be the first to know when the app is ready.",
                          style: FontStyles.sub,
                        ),
                        SizedBox(height: propHeight(20)),
                        Text(
                          "🔍 Supervised and Backed by UOS",
                          style: FontStyles.hometitle.copyWith(
                            fontSize: propText(20),
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: propHeight(10)),
                        Text(
                          "This project is developed in collaboration with the College of Health Sciences and the College of Computing and Informatics at UOS. Their expertise and supervision have ensured that EduMentor offers a top-tier educational experience.",
                          style: FontStyles.sub,
                        ),
                        SizedBox(height: propHeight(20)),
                        Text(
                          "🎯 Target Users",
                          style: FontStyles.hometitle.copyWith(
                            fontSize: propText(20),
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: propHeight(10)),
                        _buildFeature("University Students",
                            "Especially those looking for smarter ways to study and track their progress."),
                        SizedBox(height: propHeight(10)),
                        _buildFeature("Educators",
                            "Interested in offering AI-driven questions and performance feedback to students."),
                        SizedBox(height: propHeight(20)),
                        Text(
                          "📅 Version 0.1.0",
                          style: FontStyles.hometitle.copyWith(
                            fontSize: propText(20),
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: propHeight(10)),
                        Text(
                          "Initial version under development with the goal of enhancing student learning and engagement. Stay tuned for exciting updates and new features!",
                          style: FontStyles.sub,
                        ),
                        SizedBox(height: propHeight(30)),
                        Text(
                          "Created by: Ziad",
                          style: FontStyles.sub.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: propText(16),
                          ),
                        ),
                        Text(
                          "Under the supervision of the College of Health Sciences and College of Computing and Informatics at the University of Sharjah",
                          style: FontStyles.sub.copyWith(
                            fontSize: propText(14),
                          ),
                        ),
                        SizedBox(height: propHeight(20)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FontStyles.hometitle.copyWith(
            fontSize: propText(18),
            color: AppColors.black,
          ),
        ),
        SizedBox(height: propHeight(4)),
        Text(
          description,
          style: FontStyles.sub.copyWith(
            fontSize: propText(14),
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
