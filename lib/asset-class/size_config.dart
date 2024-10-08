import 'package:flutter/widgets.dart';

// Global screen configuration variables
late double screenWidth;
late double screenHeight;
late double blockSizeHorizontal;
late double blockSizeVertical;
late double safeAreaHorizontal;
late double safeAreaVertical;
late double safeBlockHorizontal;
late double safeBlockVertical;

void initSizeConfig(BuildContext context) {
  screenWidth = MediaQuery.of(context).size.width;
  screenHeight = MediaQuery.of(context).size.height;
  blockSizeHorizontal = screenWidth / 100;
  blockSizeVertical = screenHeight / 100;

  var padding = MediaQuery.of(context).padding;
  safeAreaHorizontal = screenWidth - padding.left - padding.right;
  safeAreaVertical = screenHeight - padding.top - padding.bottom;
  safeBlockHorizontal = safeAreaHorizontal / 100;
  safeBlockVertical = safeAreaVertical / 100;
}

// Global functions for proportionate sizes based on 440 x 958 design
double propHeight(double inputHeight) {
  return (inputHeight / 958) *
      screenHeight; // 958 is the base height from our design
}

double propWidth(double inputWidth) {
  return (inputWidth / 430) *
      screenWidth; // 440 is the base width from our design
}

double propText(double inputTextSize) {
  return (inputTextSize / 430) *
      screenWidth; // 440 is the base width from our design
}
