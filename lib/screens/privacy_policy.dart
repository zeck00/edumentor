import 'package:edumentor/widgets/copyright_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                  SizedBox(width: propWidth(90)),
                  Text(
                    "Privacy Policy",
                    style: FontStyles.hometitle.copyWith(
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: propHeight(20)),

              // Privacy Policy content in a scrollable container
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: propWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Privacy Policy for EduMentor Mobile Application",
                          style: FontStyles.hometitle.copyWith(
                            fontSize: propText(24),
                          ),
                        ),
                        SizedBox(height: propHeight(10)),
                        Text(
                          'Effective Date: 16th Nov, 2024',
                          style: FontStyles.sub
                              .copyWith(color: AppColors.darkGray),
                        ),
                        SizedBox(height: propHeight(20)),
                        _buildSection("Introduction",
                            "EduMentor (\"the App\") is developed under the auspices of the University of Sharjah (\"the University\") to serve as a customized tutoring assistant, specifically designed for the Health and Nutrition course. The App is committed to protecting the privacy of its users while delivering an effective learning experience. This Privacy Policy outlines how EduMentor collects, uses, and protects your information."),
                        _buildSection("1. Information We Collect", """
1.1 Personal Information:
When you register or interact with the App, we may collect personal information such as:
• Name
• Student ID
• Email address
• Academic course details

1.2 Usage Data:
The App automatically collects certain information about your device and usage of the App, including but not limited to:
• Device type and operating system
• Usage statistics and app interaction details

1.3 Academic Data:
As part of its functionality, the App may collect information such as:
• Quiz scores
• Chapter performance
• Skill assessments"""),
                        _buildSection("2. How We Use Your Information", """
The information collected is used for the following purposes:
• To personalize the tutoring experience based on your performance and preferences
• To generate customized quizzes and skill assessments
• To monitor app usage and improve its functionality
• To provide technical support"""),
                        // Add more sections following the same pattern
                        _buildSection("3. Sharing of Information", """
EduMentor does not share your personal information with third parties except:
• Within the University of Sharjah: To support academic evaluation and research under the University's guidelines
• Legal Compliance: If required to do so by law or to protect the rights, property, or safety of the University, its students, or others"""),
                        _buildSection("4. Data Security",
                            "We employ industry-standard security measures to protect your data from unauthorized access, alteration, disclosure, or destruction. However, no method of electronic storage or transmission over the internet is 100% secure, and we cannot guarantee absolute security."),
                        _buildSection("5. Contact Us", """
If you have any questions about this Privacy Policy or the App's practices, please contact us at:

University of Sharjah's IT Department
Email: servicedesk@sharjah.ac.ae

By using EduMentor, you acknowledge that you have read, understood, and agree to this Privacy Policy."""),
                        const SizedBox(height: 20),
                        const CopyrightWidget(),
                        const SizedBox(height: 20),
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

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: propHeight(20)),
        Text(
          title,
          style: FontStyles.sub.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: propWidth(16),
          ),
        ),
        SizedBox(height: propHeight(10)),
        Text(
          content,
          style: FontStyles.sub,
        ),
      ],
    );
  }
}
