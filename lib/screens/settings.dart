import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                label: 'Account Settings',
                icon: Icons.account_circle_rounded,
                onTap: () {
                  // Navigate to Account Settings screen
                },
              ),
              _settingsOption(
                label: 'Language',
                icon: Icons.language_rounded,
                onTap: () {
                  // Show language selection
                },
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
                onTap: () {
                  // Navigate to Help & Support
                },
              ),
              SizedBox(height: propHeight(30)),

              // Legal and Privacy Section
              Text("Legal & Privacy", style: FontStyles.hometitle),
              SizedBox(height: propHeight(20)),
              _settingsOption(
                label: 'Terms of Service',
                icon: Icons.assignment_rounded,
                onTap: () {
                  // Navigate to Terms of Service
                },
              ),
              _settingsOption(
                label: 'Privacy Policy',
                icon: Icons.privacy_tip_rounded,
                onTap: () {
                  // Navigate to Privacy Policy
                },
              ),
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
