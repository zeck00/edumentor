import 'package:flutter/material.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:edumentor/widgets/copyright_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
                  SizedBox(width: propWidth(40)),
                  Text(
                    "Terms and Conditions",
                    style: FontStyles.hometitle.copyWith(
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: propHeight(20)),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(propWidth(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms and Conditions for EduMentor Mobile Application',
                        style: FontStyles.hometitle,
                      ),
                      SizedBox(height: propHeight(10)),
                      Text(
                        'Effective Date: 16th Nov, 2024',
                        style:
                            FontStyles.sub.copyWith(color: AppColors.darkGray),
                      ),
                      _buildSection('Introduction',
                          'Welcome to EduMentor, a mobile application developed under the auspices of the University of Sharjah ("the University"). By accessing or using EduMentor ("the App"), you agree to comply with these Terms and Conditions ("Terms"). These Terms govern your use of the App and outline the rights and responsibilities of all parties involved. If you do not agree to these Terms, please refrain from using the App.'),
                      _buildSection(
                          '1. Acceptance of Terms',
                          'By registering for and using EduMentor, you confirm that:\n\n'
                              '• You are a student or staff member of the University of Sharjah or have obtained explicit permission to use the App.\n\n'
                              '• You have read and agree to be bound by these Terms and any applicable University policies.'),
                      _buildSection('2. Purpose of the App',
                          'EduMentor is designed to provide personalized tutoring and educational support, specifically for the Health and Nutrition course. The App\'s features are intended to enhance learning outcomes and facilitate academic success.'),
                      _buildSection(
                          '3. User Accounts',
                          '3.1 Registration:\n'
                              'You must register using valid University credentials or other approved methods. You are responsible for maintaining the confidentiality of your account credentials.\n\n'
                              '3.2 Account Suspension or Termination:\n'
                              'The University reserves the right to suspend or terminate accounts if:\n\n'
                              '• You violate these Terms.\n'
                              '• Unauthorized activity is detected.\n'
                              '• Your enrollment at the University ends.'),
                      _buildSection(
                          '4. User Responsibilities',
                          'By using EduMentor, you agree to:\n\n'
                              '• Use the App solely for educational purposes.\n'
                              '• Provide accurate and up-to-date information.\n'
                              '• Not engage in activities that disrupt or interfere with the App\'s functionality.\n'
                              '• Respect the intellectual property rights associated with the App\'s content and features.'),
                      _buildSection(
                          '5. Prohibited Activities',
                          'You agree not to:\n\n'
                              '• Attempt to hack, reverse-engineer, or otherwise tamper with the App.\n'
                              '• Share or distribute copyrighted materials accessed via the App without proper authorization.\n'
                              '• Use the App for any activity that violates University policies or UAE laws.'),
                      _buildSection('6. Intellectual Property Rights',
                          'All intellectual property related to EduMentor, including but not limited to content, features, logos, and design, is the property of the University of Sharjah or its licensors. Unauthorized use, reproduction, or distribution is strictly prohibited.'),
                      _buildSection(
                          '7. Limitation of Liability',
                          'The University of Sharjah is not liable for:\n\n'
                              '• Any loss or damage resulting from your use of the App.\n'
                              '• Interruptions or errors in App functionality.\n'
                              '• Unauthorized access to your account due to negligence in securing your credentials.'),
                      _buildSection('8. Modifications to the App',
                          'The University reserves the right to update, modify, or discontinue EduMentor or any of its features without prior notice. Efforts will be made to inform users of significant changes through appropriate communication channels.'),
                      _buildSection('9. Data Collection and Privacy',
                          'Your use of EduMentor is subject to the Privacy Policy, which explains how your data is collected, used, and protected. By using the App, you consent to the terms outlined in the Privacy Policy.'),
                      _buildSection('10. Third-Party Services',
                          'EduMentor may integrate third-party services to enhance its functionality. These services are governed by their own terms and conditions, and the University does not assume liability for issues arising from their use.'),
                      _buildSection('11. Governing Law',
                          'These Terms are governed by the laws of the United Arab Emirates. Any disputes arising from your use of the App shall be resolved under the jurisdiction of UAE courts.'),
                      _buildSection(
                          '12. Contact Information',
                          'For questions or concerns about these Terms, please contact:\n\n'
                              'University of Sharjah, IT Department\n'
                              'Email: servicedesk@sharjah.ac.ae\n\n'
                              'By accessing and using EduMentor, you acknowledge that you have read, understood, and agreed to these Terms and Conditions.'),
                      const SizedBox(height: 20),
                      const CopyrightWidget(),
                      const SizedBox(height: 20),
                    ],
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
