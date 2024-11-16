import 'package:edumentor/asset-class/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CopyrightWidget extends StatelessWidget {
  const CopyrightWidget({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://sharjah.ac.ae');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: FontStyles.sub.copyWith(
          fontSize: 12,
          color: Colors.grey[600],
        ),
        children: [
          const TextSpan(text: '© 2024 Edu'),
          const TextSpan(
              text: 'Mentor ', style: TextStyle(color: AppColors.green)),
          const TextSpan(text: 'from '),
          TextSpan(
            text: 'University Of Sharjah',
            style: FontStyles.sub.copyWith(
              fontSize: 12,
              color: AppColors.green,
            ),
            recognizer: TapGestureRecognizer()..onTap = _launchURL,
          ),
          const TextSpan(text: '. All rights reserved.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
