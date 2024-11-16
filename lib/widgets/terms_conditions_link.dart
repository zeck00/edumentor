import 'package:flutter/material.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/screens/terms_conditions.dart';

class TermsConditionsLink extends StatelessWidget {
  const TermsConditionsLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TermsConditionsScreen(),
          ),
        );
      },
      child: Text(
        'Terms & Conditions',
        style: FontStyles.sub.copyWith(
          color: AppColors.green,
        ),
      ),
    );
  }
}
