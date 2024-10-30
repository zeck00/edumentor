import 'package:edumentor/screens/aboutus.dart';
import 'package:edumentor/screens/chapters.dart';
import 'package:edumentor/screens/course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<String> _selectedCourseNotifier =
      ValueNotifier('Select a Course');
  final List<String> _courses = [
    'Health Awareness and Nutrition',
    'Coming Soon...',
  ];

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
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
                      onTap: () {
                        // Handle profile tap
                      },
                      child: CircleAvatar(
                        radius: propWidth(22.5),
                        backgroundColor: AppColors.black,
                        child: SvgPicture.asset('assets/profile.svg'),
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
                    // if (newValue == 'Health Awareness and Nutrition') {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => ChapterSelectionScreen(),
                    //     ),
                    //   );
                    // }
                    // _selectedCourseNotifier.value = newValue;
                  },
                  showSeparator: true,
                  showMode: MiraiShowMode.bottom,
                  maxHeight: propHeight(150),
                  child: Container(
                    key: GlobalKey(), // Add this key
                    padding: EdgeInsets.symmetric(horizontal: propWidth(15)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(propHeight(15)),
                      border: Border.all(
                          color: AppColors.black, width: propHeight(1.5)),
                    ),
                    height: propHeight(50),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterSelectionScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("EduMentor AI", style: FontStyles.hometitle),
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
                        builder: (context) => ChapterSelectionScreen(),
                      ),
                    );
                  },
                  child: _customCard('assets/EduMentor.png'),
                ),
                SizedBox(height: propHeight(20)),

                // Course Material Section
                GestureDetector(
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

                // Course Material Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseMaterialPage(),
                      ),
                    );
                  },
                  child: _customCard('assets/CourseMaterial.png'),
                ),
                SizedBox(height: propHeight(30)),

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
                            builder: (context) => AboutUsPage(),
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
    Key? key,
    required this.item,
    required this.isItemSelected,
  }) : super(key: key);

  final String item;
  final bool isItemSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: propHeight(15), horizontal: propWidth(15)),
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
