import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:edumentor/services/auth_service.dart';
import 'package:edumentor/screens/login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                  Text("Profile", style: FontStyles.hometitle),
                  SizedBox(width: propWidth(30)), // Placeholder for alignment
                ],
              ),
              SizedBox(height: propHeight(30)),

              // Profile Picture and Name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: propWidth(50),
                      backgroundColor: AppColors.gray,
                      child: SvgPicture.asset('assets/profile.svg'),
                    ),
                    SizedBox(height: propHeight(15)),
                    Text(
                      'User Name',
                      style: FontStyles.hometitle.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: propHeight(5)),
                    Text(
                      'user@example.com',
                      style: FontStyles.sub.copyWith(
                        color: AppColors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: propHeight(30)),

              // Account Settings Section
              Text("Account Settings", style: FontStyles.hometitle),
              SizedBox(height: propHeight(20)),
              _profileOption(
                label: 'Edit Profile',
                icon: Icons.edit_note_rounded,
                onTap: () {
                  // Navigate to Edit Profile screen
                },
              ),
              _profileOption(
                label: 'Privacy Settings',
                icon: Icons.privacy_tip_rounded,
                onTap: () {
                  // Navigate to Privacy Settings screen
                },
              ),
              _profileOption(
                label: 'Delete Account',
                icon: Icons.delete_forever_rounded,
                onTap: () {
                  // Show language selection
                },
              ),
              SizedBox(height: propHeight(30)),

              // Logout Button
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await AuthService.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    width: propWidth(175),
                    height: propHeight(55),
                    decoration: BoxDecoration(
                      color: AppColors.gray,
                      borderRadius: BorderRadius.circular(propWidth(25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Logout',
                          style: FontStyles.button1.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        Icon(Icons.logout_rounded)
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

  // Widget for each profile option
  Widget _profileOption({
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
                Icon(icon),
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
