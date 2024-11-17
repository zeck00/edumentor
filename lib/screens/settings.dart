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
                label: 'Logout',
                icon: Icons.logout_rounded,
                color: AppColors.red,
                onTap: () async {
                  // Show enhanced confirmation dialog
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(propWidth(20)),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: propWidth(20),
                            vertical: propHeight(20),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(propWidth(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: const Offset(0.0, 10.0),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(propWidth(16)),
                                decoration: BoxDecoration(
                                  color: AppColors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.red,
                                  size: propWidth(32),
                                ),
                              ),
                              SizedBox(height: propHeight(15)),
                              Text(
                                'Logout',
                                style: FontStyles.sub.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: propWidth(20),
                                ),
                              ),
                              SizedBox(height: propHeight(15)),
                              Text(
                                'Are you sure you want to logout?',
                                textAlign: TextAlign.center,
                                style: FontStyles.sub.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: propHeight(20)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: propHeight(12)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              propWidth(10)),
                                          side:
                                              BorderSide(color: AppColors.red),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: FontStyles.sub.copyWith(
                                          color: AppColors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: propWidth(10)),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: propHeight(12)),
                                        backgroundColor: AppColors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              propWidth(10)),
                                        ),
                                      ),
                                      child: Text(
                                        'Logout',
                                        style: FontStyles.sub.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
    Color color = AppColors.black,
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
          border: Border.all(color: color, width: propHeight(1)),
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
                Icon(icon, size: propHeight(30), color: color),
                SizedBox(width: propWidth(15)),
                Text(
                  label,
                  style: FontStyles.sub.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: propHeight(20),
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
