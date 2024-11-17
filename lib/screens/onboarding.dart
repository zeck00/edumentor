import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:edumentor/screens/login.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('showedOnboarding') ?? false);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  bool isLastPage = false;
  late Timer _autoSlideTimer;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Practice with AI-Generated Questions',
      description:
          'Get personalized MCQs based on your performance and learning needs',
      image: 'assets/images/onboarding_questions.png',
    ),
    OnboardingItem(
      title: 'Track Your Progress',
      description:
          'Monitor your performance across different chapters and topics',
      image: 'assets/images/onboarding_progress.png',
    ),
    OnboardingItem(
      title: 'Get Personalized Feedback',
      description:
          'Receive detailed feedback and recommendations to improve your learning',
      image: 'assets/images/onboarding_feedback.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlideTimer();
  }

  @override
  void dispose() {
    _autoSlideTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_controller.page == _items.length - 1) {
        _controller.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _controller.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == _items.length - 1;
              });
            },
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return OnboardingPage(item: _items[index]);
            },
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: propWidth(16),
                vertical: propHeight(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: propHeight(75),
                    width: propWidth(75),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(propWidth(10)),
                      color: AppColors.white,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: propWidth(10),
                      vertical: propHeight(10),
                    ),
                    child: SvgPicture.asset(
                      'assets/logo.svg',
                      height: propHeight(55),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: propWidth(20),
                vertical: propHeight(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isLastPage)
                    TextButton(
                      onPressed: () => _skipOnboarding(),
                      child: Text(
                        'Skip',
                        style: FontStyles.sub.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 110),
                  const Spacer(),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _items.length,
                    effect: WormEffect(
                      spacing: propWidth(16),
                      dotColor: AppColors.white.withOpacity(0.3),
                      activeDotColor: AppColors.white,
                      dotHeight: propHeight(10),
                      dotWidth: propWidth(10),
                    ),
                    onDotClicked: (index) => _controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (isLastPage) {
                        _skipOnboarding();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      isLastPage ? 'Get Started' : 'Next',
                      style: FontStyles.sub.copyWith(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showedOnboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          item.image,
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.black.withOpacity(0.7),
                AppColors.black.withOpacity(0.9),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: propHeight(120),
          left: propWidth(20),
          right: propWidth(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: item.title.split(' ')[0],
                      style: FontStyles.hometitle.copyWith(
                        color: AppColors.white,
                        fontSize: propWidth(28),
                      ),
                    ),
                    TextSpan(
                      text: ' ${item.title.split(' ')[1]}',
                      style: FontStyles.hometitleg.copyWith(
                        color: AppColors.green,
                        fontSize: propWidth(28),
                      ),
                    ),
                    TextSpan(
                      text: ' ${item.title.split(' ').sublist(2).join(' ')}',
                      style: FontStyles.hometitle.copyWith(
                        color: AppColors.white,
                        fontSize: propWidth(28),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: propHeight(16)),
              Text(
                item.description,
                style: FontStyles.sub.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: propWidth(16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
