import 'package:edumentor/asset-class/size_config.dart';
import 'package:flutter/material.dart';

class FontStyles {
  static const Color defaultColor = Color(0xFF2F2F2F); // Default color

  // Title (inter bold, size 32)
  static final TextStyle title = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700, // Bold
    fontSize: propText(32),
    color: defaultColor,
  );

  // Sub (inter regular, size 14)
  static final TextStyle sub = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400, // Regular
    fontSize: propText(14),
    color: defaultColor,
  );

  // Sub with green color (inter regular, size 14, color #39B285)
  static final TextStyle subg = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400, // Regular
    fontSize: propText(14),
    color: const Color(0xFF39B285),
  );

  // Button (inter bold, size 20, color #f3f3f3)
  static final TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700, // Bold
    fontSize: propText(20),
    color: const Color(0xFFF3F3F3),
  );

  // News title (inter semibold, size 14, color #f3f3f3)
  static final TextStyle newstitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600, // Semi-bold
    fontSize: propText(14),
    color: const Color(0xFFF3F3F3),
  );

  // Home title (inter bold, size 24)
  static final TextStyle hometitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700, // Bold
    fontSize: propText(24),
    color: defaultColor,
  );

  // Home title with green color (inter bold, size 24, color #39B285)
  static final TextStyle hometitleg = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700, // Bold
    fontSize: propText(24),
    color: const Color(0xFF39B285),
  );

  // Button1 (inter semibold, size 20)
  static final TextStyle button1 = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600, // Semi-bold
    fontSize: propText(20),
    color: defaultColor,
  );
}
