import 'package:edumentor/widgets/copyright_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launchLinkedIn() async {
    final Uri url = Uri.parse('https://www.linkedin.com/in/ziad-aloush/');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    Widget buildDevelopmentTeamSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Development Team",
            style: FontStyles.hometitle.copyWith(
              fontSize: propText(20),
              color: AppColors.black,
            ),
          ),
          SizedBox(height: propHeight(10)),
          RichText(
            text: TextSpan(
              style: FontStyles.sub,
              children: [
                const TextSpan(
                  text: "At the heart of EduMentor's creation is ",
                ),
                TextSpan(
                  text: "Ziad Ahmad",
                  style: FontStyles.sub.copyWith(
                    color: AppColors.green,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _launchLinkedIn,
                ),
                const TextSpan(
                  text:
                      " 💻✨, the app's main developer. Ziad combined his skills in programming, artificial intelligence 🤖, and user experience design 🎨 to bring the vision of EduMentor to life. His dedication and technical expertise ensured the app meets the highest standards of quality and usability 🔝✅.",
                ),
              ],
            ),
          ),
          SizedBox(height: propHeight(20)),
        ],
      );
    }

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
                                  text: 'Edu', style: FontStyles.hometitle),
                              TextSpan(
                                  text: 'Mentor', style: FontStyles.hometitleg),
                            ],
                          ),
                        ),
                        SizedBox(height: propHeight(10)),
                        Text(
                          "EduMentor is a groundbreaking mobile application designed to revolutionize the learning experience for students at the University of Sharjah (UOS) 📚📱. Tailored specifically for students, EduMentor combines personalized tutoring with cutting-edge technology 💡🔬 to assess and enhance student skills.",
                          style: FontStyles.sub,
                        ),
                        SizedBox(height: propHeight(20)),
                        _buildSection(
                          "Our Story",
                          "EduMentor was developed with the generous support of a grant from the Chancellor of the University of Sharjah 🎓🤝. The project was a collaborative effort, bringing together expertise and passion 💪💼 from multiple disciplines to create a tool that truly supports student success 🏆.",
                        ),
                        _buildSection(
                          "Supervision and Guidance",
                          "The development of EduMentor was supervised by:\n\n"
                              "Dr. Ayad Turky 👨‍🏫💻, Assistant Professor in the Department of Computer Science, whose technical insights and guidance shaped the app's functionality.\n\n"
                              "Prof. Mohamed Alameddine 👨‍⚕️📖, Dean of the College of Health Sciences, who provided invaluable direction to ensure the app's alignment with educational needs in the health sciences field.\n\n"
                              "Prof. Abbes Amira 👨‍💻🏛️, Dean of the College of Computing and Informatics, whose leadership in computing innovation supported the app's technical excellence.",
                        ),
                        buildDevelopmentTeamSection(),
                        _buildSection(
                          "Our Mission",
                          "Our mission is to empower students with tools 🛠️ that enhance their learning, provide real-time feedback ⏱️, and foster academic growth 📈. By leveraging AI-driven insights and personalized assessments 🧠📊, EduMentor aims to help every student reach their full potential 🌟.",
                        ),
                        _buildSection(
                          "Acknowledgments",
                          "EduMentor is a testament to the collaborative spirit of the University of Sharjah 🤝🏫. We thank all faculty members, students, and staff who contributed to its development and success 🙏🎉. Together, we strive to create innovative solutions that benefit our academic community and beyond 🌍✨.",
                        ),
                        SizedBox(height: propHeight(20)),
                        Center(child: const CopyrightWidget()),
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
        Text(
          title,
          style: FontStyles.hometitle.copyWith(
            fontSize: propText(20),
            color: AppColors.black,
          ),
        ),
        SizedBox(height: propHeight(10)),
        Text(
          content,
          style: FontStyles.sub,
        ),
        SizedBox(height: propHeight(20)),
      ],
    );
  }
}
