import 'package:edumentor/widgets/copyright_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:edumentor/screens/terms_conditions.dart';
import 'package:edumentor/screens/privacy_policy.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edumentor/services/auth_service.dart';
import 'package:edumentor/screens/login.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _launchUOSWebsite() async {
    final Uri url = Uri.parse('https://sharjah.ac.ae');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showLanguageSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.language_rounded, color: AppColors.white),
            SizedBox(width: propWidth(20)),
            Flexible(
              child: Text(
                "We're working on adding more languages soon!✨",
                style: FontStyles.sub.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(propWidth(10)),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: propWidth(16),
          vertical: propHeight(16),
        ),
      ),
    );
  }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text("Settings", style: FontStyles.hometitle),
                  SizedBox(width: propWidth(30)), // Placeholder for alignment
                ],
              ),
              SizedBox(height: propHeight(30)),

              // Settings Options Section
              Text("General", style: FontStyles.hometitle),
              SizedBox(height: propHeight(20)),
              _settingsOption(
                label: 'Notifications',
                icon: Icons.notifications_on_rounded,
                onTap: () {
                  // Navigate to Notifications Settings
                },
              ),
              _settingsOption(
                label: 'Logout',
                icon: Icons.logout_rounded,
                onTap: () async {
                  // Show confirmation dialog
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Confirm Logout',
                          style: FontStyles.sub.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: FontStyles.sub,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'Cancel',
                              style: FontStyles.sub.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Logout',
                              style: FontStyles.sub.copyWith(
                                color: AppColors.green,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await AuthService.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
              _settingsOption(
                label: 'Language',
                icon: Icons.language_rounded,
                onTap: () => _showLanguageSnackbar(context),
              ),
              SizedBox(height: propHeight(30)),

              // App Settings Section
              Text("App Preferences", style: FontStyles.hometitle),
              SizedBox(height: propHeight(20)),
              _settingsOption(
                label: 'Review App',
                icon: Icons.reviews_rounded,
                onTap: () {
                  // Navigate to Review page
                },
              ),
              _settingsOption(
                label: 'Help & Support',
                icon: Icons.help_outline_rounded,
                onTap: () => _launchUOSWebsite(),
              ),
              SizedBox(height: propHeight(30)),

              // Legal and Privacy Section
              Text("Legal & Privacy", style: FontStyles.hometitle),
              SizedBox(height: propHeight(20)),
              _settingsOption(
                label: 'Terms of Service',
                icon: Icons.assignment_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsConditionsScreen(),
                    ),
                  );
                },
              ),
              _settingsOption(
                label: 'Privacy Policy',
                icon: Icons.privacy_tip_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: propHeight(20)),
              Center(child: const CopyrightWidget()),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for each settings option
  Widget _settingsOption({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: propHeight(15),
          horizontal: propWidth(20),
        ),
        margin: EdgeInsets.only(bottom: propHeight(10)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(propWidth(15)),
          border: Border.all(color: AppColors.black, width: propHeight(1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: propHeight(5),
              offset: Offset(0, propHeight(5)),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: propHeight(30), color: AppColors.black),
                SizedBox(width: propWidth(15)),
                Text(
                  label,
                  style: FontStyles.sub.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: propHeight(20),
              color: AppColors.black,
            ),
          ],
        ),
      ),
    );
  }
}
