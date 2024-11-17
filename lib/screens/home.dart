import 'package:edumentor/screens/aboutus.dart';
import 'package:edumentor/screens/course.dart';
import 'package:edumentor/screens/profile.dart';
import 'package:edumentor/screens/questions.dart';
import 'package:edumentor/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:edumentor/services/streak.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<String> _selectedCourseNotifier =
      ValueNotifier('Select a Course');
  ValueNotifier<int> _streakNotifier = ValueNotifier(0);
  final List<String> _courses = [
    'Health Awareness and Nutrition',
    'Coming Soon...',
  ];
  late ConfettiController _confettiController;
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];
  final GlobalKey courseSelectionKey = GlobalKey();
  final GlobalKey streakKey = GlobalKey();
  final GlobalKey eduMentorAIKey = GlobalKey();
  final GlobalKey courseMaterialKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _updateStreak();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeUser();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _updateStreak() async {
    await StreakService.updateStreak();
    final streak = await StreakService.getCurrentStreak();
    _streakNotifier.value = streak;
  }

  double _getRandomEmissionFrequency() {
    return 0.05 + (Random().nextDouble() * 0.02);
  }

  void _showStreakFlushbar() {
    Flushbar(
      messageText: GestureDetector(
        onTap: () => _confettiController.play(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(propWidth(20)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: propWidth(20),
            vertical: propHeight(10),
          ),
          child: Row(
            children: [
              // Fire Icon with background circle
              Container(
                width: propHeight(50),
                height: propHeight(50),
                decoration: const BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: propHeight(30),
                ),
              ),
              SizedBox(width: propWidth(20)),
              // Text Column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Streak",
                      style: TextStyle(
                        fontSize: propHeight(18),
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: propHeight(5)),
                    ValueListenableBuilder<int>(
                      valueListenable: _streakNotifier,
                      builder: (context, streak, child) {
                        return Text(
                          "$streak ${streak == 1 ? 'Day' : 'Days'}",
                          style: TextStyle(
                            fontSize: propHeight(22),
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 4),
      isDismissible: true,
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.all(propWidth(16)),
      borderRadius: BorderRadius.circular(propWidth(20)),
      boxShadows: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: propHeight(2),
          blurRadius: propHeight(10),
          offset: const Offset(0, 3),
        ),
      ],
    ).show(context);
  }

  Future<void> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time_user') ?? true;

    if (isFirstTime) {
      _initTargets();
      _showTutorial();
      await prefs.setBool('first_time_user', false);
    }
  }

  void _initTargets() {
    targets.addAll([
      TargetFocus(
        identify: "courseSelection",
        keyTarget: courseSelectionKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: EdgeInsets.all(propWidth(15)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(propWidth(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school_rounded, color: AppColors.green),
                        SizedBox(width: propWidth(10)),
                        Text(
                          "Course Selection",
                          style: FontStyles.hometitle.copyWith(
                            color: AppColors.black,
                            fontSize: propWidth(20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: propHeight(10)),
                    Text(
                      "Select your course here to access course-specific materials and quizzes.",
                      style: FontStyles.sub.copyWith(
                        color: AppColors.black,
                        fontSize: propWidth(16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "streak",
        keyTarget: streakKey,
        shape: ShapeLightFocus.Circle,
        radius: 25,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: EdgeInsets.all(propWidth(15)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(propWidth(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            color: Colors.orangeAccent),
                        SizedBox(width: propWidth(10)),
                        Text(
                          "Daily Streak",
                          style: FontStyles.hometitle.copyWith(
                            color: AppColors.black,
                            fontSize: propWidth(20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: propHeight(10)),
                    Text(
                      "Track your learning consistency! Keep your streak going by studying daily.",
                      style: FontStyles.sub.copyWith(
                        color: AppColors.black,
                        fontSize: propWidth(16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "eduMentorAI",
        keyTarget: eduMentorAIKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: EdgeInsets.all(propWidth(15)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(propWidth(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology_alt_rounded,
                            color: AppColors.green),
                        SizedBox(width: propWidth(10)),
                        Text(
                          "EduMentor AI",
                          style: FontStyles.hometitle.copyWith(
                            color: AppColors.black,
                            fontSize: propWidth(20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: propHeight(10)),
                    Text(
                      "Practice with AI-generated questions tailored to your performance level.",
                      style: FontStyles.sub.copyWith(
                        color: AppColors.black,
                        fontSize: propWidth(16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "courseMaterial",
        keyTarget: courseMaterialKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: EdgeInsets.all(propWidth(15)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(propWidth(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, color: AppColors.green),
                        SizedBox(width: propWidth(10)),
                        Text(
                          "Course Material",
                          style: FontStyles.hometitle.copyWith(
                            color: AppColors.black,
                            fontSize: propWidth(20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: propHeight(10)),
                    Text(
                      "Access your course materials, lectures, and study resources here.",
                      style: FontStyles.sub.copyWith(
                        color: AppColors.black,
                        fontSize: propWidth(16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ]);
  }

  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.green.withOpacity(0.8),
      textSkip: "SKIP TUTORIAL",
      paddingFocus: 5,
      opacityShadow: 0.8,
      textStyleSkip: FontStyles.sub.copyWith(
        color: Colors.white,
        fontSize: propWidth(16),
        fontWeight: FontWeight.bold,
      ),
      onFinish: () {
        print("Tutorial finished");
        return true;
      },
      onSkip: () {
        print("Tutorial skipped");
        return true;
      },
    )..show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: propWidth(16),
                  vertical: propHeight(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar with logo and profile icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(
                          'assets/logo.svg',
                          height: propHeight(55),
                        ),
                        InkWell(
                          key: streakKey,
                          onTap: () {
                            _showStreakFlushbar();
                          },
                          child: Container(
                            width: propHeight(50),
                            height: propHeight(50),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: propHeight(30),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: propHeight(20)),
                    // MiraiDropdownWidget for Course Selection
                    Text(
                      "Select a Course",
                      style: FontStyles.hometitle,
                    ),
                    SizedBox(height: propHeight(10)),

                    MiraiDropDownMenu<String>(
                      key: courseSelectionKey,
                      valueNotifier: _selectedCourseNotifier,
                      itemWidgetBuilder: (int index, String? item,
                          {bool isItemSelected = false}) {
                        return MiraiDropDownItemWidget(
                          item: item ?? '',
                          isItemSelected: isItemSelected,
                        );
                      },
                      children: _courses,
                      onChanged: (String newValue) {
                        if (newValue == 'Health Awareness and Nutrition') {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => ChapterSelectionScreen(),
                          //   ),
                          // );
                        }
                        _selectedCourseNotifier.value = newValue;
                      },
                      showSeparator: true,
                      showMode: MiraiShowMode.bottom,
                      maxHeight: propHeight(150),
                      child: Container(
                        key: GlobalKey(), // Add this key
                        padding:
                            EdgeInsets.symmetric(horizontal: propWidth(15)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(propHeight(20)),
                          border: Border.all(
                              color: AppColors.black, width: propHeight(1.5)),
                        ),
                        height: propHeight(60),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            ValueListenableBuilder<String>(
                              valueListenable: _selectedCourseNotifier,
                              builder: (_, String chosenTitle, __) {
                                return Text(
                                  chosenTitle,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: propHeight(40),
                              color: AppColors.black,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: propHeight(15)),

                    // EduMentor AI Section
                    GestureDetector(
                      key: eduMentorAIKey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MCQQuizScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Edu', style: FontStyles.hometitle),
                                TextSpan(
                                    text: 'Mentor',
                                    style: FontStyles.hometitleg),
                                TextSpan(
                                    text: ' AI', style: FontStyles.hometitle),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/g-next.svg',
                            height: propHeight(30),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: propHeight(10)),

                    // EduMentor AI Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MCQQuizScreen(),
                          ),
                        );
                      },
                      child: _customCard('assets/EduMentor.png'),
                    ),
                    SizedBox(height: propHeight(20)),

                    // Course Material Section
                    GestureDetector(
                      key: courseMaterialKey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseMaterialPage(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Course Material", style: FontStyles.hometitle),
                          SvgPicture.asset(
                            'assets/b-next.svg',
                            height: propHeight(30),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: propHeight(10)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseMaterialPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: propHeight(225),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(propWidth(25)),
                          image: DecorationImage(
                            alignment: Alignment.center,
                            image: AssetImage('assets/CourseMaterial.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: propHeight(20)),

                    // Bottom Buttons (Settings & About Us)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _bottomButton(
                          "Settings",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(),
                              ),
                            );
                          },
                        ),
                        _bottomButton(
                          "About Us",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutUsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 10,
              minBlastForce: 7,
              particleDrag: .05,
              emissionFrequency: _getRandomEmissionFrequency(),
              numberOfParticles: 22,
              gravity: 0.3,
              shouldLoop: false,
              colors: [
                AppColors.green,
                AppColors.blue,
                AppColors.darkGray,
                AppColors.lightGray
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customCard(String imagePath) {
    return Container(
      width: double.infinity,
      height: propHeight(225),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(propWidth(25)),
        image: DecorationImage(
          alignment: Alignment.center,
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _bottomButton(String label, onTap) {
    return GestureDetector(
      onTap: onTap,
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
              label,
              style: FontStyles.button1.copyWith(color: AppColors.black),
            ),
            SvgPicture.asset(
              'assets/b-next.svg',
              height: propHeight(30),
            ),
          ],
        ),
      ),
    );
  }
}

class MiraiDropDownItemWidget extends StatelessWidget {
  const MiraiDropDownItemWidget({
    super.key,
    required this.item,
    required this.isItemSelected,
  });

  final String item;
  final bool isItemSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: propHeight(4), horizontal: propWidth(10)),
      child: Text(
        item,
        style: TextStyle(
          color: isItemSelected ? Colors.white : Colors.black,
          fontWeight: isItemSelected ? FontWeight.bold : FontWeight.bold,
        ),
      ),
    );
  }
}
