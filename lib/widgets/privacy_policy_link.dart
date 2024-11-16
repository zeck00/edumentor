import 'package:flutter/material.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/screens/privacy_policy.dart';

class PrivacyPolicyLink extends StatelessWidget {
  const PrivacyPolicyLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PrivacyPolicyScreen(),
          ),
        );
      },
      child: Text(
        'Privacy Policy',
        style: FontStyles.sub.copyWith(
          color: AppColors.green,
        ),
      ),
    );
  }
}
