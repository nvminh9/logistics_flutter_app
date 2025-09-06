import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResponsiveHelper {
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static double _blockSizeHorizontal = 0;
  static double _blockSizeVertical = 0;
  static double _safeAreaHorizontal = 0;
  static double _safeAreaVertical = 0;
  static double safeBlockHorizontal = 0;
  static double safeBlockVertical = 0;

  static void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    _safeAreaHorizontal = mediaQuery.padding.left + mediaQuery.padding.right;
    _safeAreaVertical = mediaQuery.padding.top + mediaQuery.padding.bottom;
    safeBlockHorizontal = (_screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (_screenHeight - _safeAreaVertical) / 100;
  }

  // Screen dimensions
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;

  // Responsive width (percentage of screen width)
  static double wp(double percentage) => percentage * _blockSizeHorizontal;

  // Responsive height (percentage of screen height)
  static double hp(double percentage) => percentage * _blockSizeVertical;

  // Safe area responsive width
  static double swp(double percentage) => percentage * safeBlockHorizontal;

  // Safe area responsive height
  static double shp(double percentage) => percentage * safeBlockVertical;

  // Responsive font size
  static double sp(double size) {
    return size * (_screenWidth / 375); // 375 is iPhone 6/7/8 width
  }

  // Device type detection
  static bool get isSmallScreen => _screenWidth < 350;
  static bool get isMediumScreen => _screenWidth >= 350 && _screenWidth < 400;
  static bool get isLargeScreen => _screenWidth >= 400;
  static bool get isTablet => _screenWidth > 600;

  // Screen density
  static double get pixelRatio => WidgetsBinding.instance.window.devicePixelRatio;

  // Responsive padding/margin
  static EdgeInsets get defaultPadding {
    if (isSmallScreen) {
      return EdgeInsets.symmetric(horizontal: wp(4), vertical: hp(2));
    } else if (isMediumScreen) {
      return EdgeInsets.symmetric(horizontal: wp(5), vertical: hp(2.5));
    } else {
      return EdgeInsets.symmetric(horizontal: wp(6), vertical: hp(3));
    }
  }

  static EdgeInsets get cardPadding {
    if (isSmallScreen) {
      // return EdgeInsets.all(wp(4));
      return EdgeInsets.all(wp(2));
    } else if (isMediumScreen) {
      // return EdgeInsets.all(wp(5));
      return EdgeInsets.all(wp(2));
    } else {
      // return EdgeInsets.all(wp(6));
      return EdgeInsets.all(wp(3));
    }
  }

  // Responsive border radius
  static double get cardBorderRadius {
    if (isSmallScreen) return wp(3);
    if (isMediumScreen) return wp(3);
    return wp(3);
  }

  static double get buttonBorderRadius {
    if (isSmallScreen) return wp(2.5);
    if (isMediumScreen) return wp(3);
    return wp(4);
  }

  // Responsive spacing
  static double get smallSpacing => isSmallScreen ? hp(1) : hp(1.5);
  static double get mediumSpacing => isSmallScreen ? hp(2) : hp(2.5);
  static double get largeSpacing => isSmallScreen ? hp(3) : hp(4);

  // Button heights
  static double get buttonHeight {
    if (isSmallScreen) return hp(6);
    if (isMediumScreen) return hp(7);
    return hp(8);
  }

  // Icon sizes
  static double get smallIcon => isSmallScreen ? wp(4) : wp(5);
  static double get mediumIcon => isSmallScreen ? wp(5) : wp(6);
  static double get largeIcon => isSmallScreen ? wp(8) : wp(10);

  // Card heights
  static double get orderCardHeight {
    if (isSmallScreen) return hp(20);
    if (isMediumScreen) return hp(22);
    return hp(25);
  }
}