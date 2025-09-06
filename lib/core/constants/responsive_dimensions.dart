import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/utils/responsive_helper.dart';

class ResponsiveDimensions {
  // Font Sizes
  static double get headlineLarge => ResponsiveHelper.sp(32);
  static double get headlineMedium => ResponsiveHelper.sp(28);
  static double get headlineSmall => ResponsiveHelper.sp(24);
  static double get titleLarge => ResponsiveHelper.sp(22);
  static double get titleMedium => ResponsiveHelper.sp(18);
  static double get titleSmall => ResponsiveHelper.sp(16);
  static double get bodyLarge => ResponsiveHelper.sp(16);
  static double get bodyMedium => ResponsiveHelper.sp(14);
  static double get bodySmall => ResponsiveHelper.sp(12);
  static double get labelLarge => ResponsiveHelper.sp(14);
  static double get labelMedium => ResponsiveHelper.sp(12);
  static double get labelSmall => ResponsiveHelper.sp(10);

  // Spacing
  static double get spacingXS => ResponsiveHelper.wp(1);
  static double get spacingS => ResponsiveHelper.wp(2);
  static double get spacingM => ResponsiveHelper.wp(4);
  static double get spacingL => ResponsiveHelper.wp(6);
  static double get spacingXL => ResponsiveHelper.wp(8);

  // Padding
  static EdgeInsets get paddingS => EdgeInsets.all(ResponsiveHelper.wp(2));
  static EdgeInsets get paddingM => EdgeInsets.all(ResponsiveHelper.wp(4));
  static EdgeInsets get paddingL => EdgeInsets.all(ResponsiveHelper.wp(6));
  static EdgeInsets get paddingXL => EdgeInsets.all(ResponsiveHelper.wp(8));

  // Margins
  static EdgeInsets get marginS => EdgeInsets.all(ResponsiveHelper.wp(2));
  static EdgeInsets get marginM => EdgeInsets.all(ResponsiveHelper.wp(4));
  static EdgeInsets get marginL => EdgeInsets.all(ResponsiveHelper.wp(6));
  static EdgeInsets get marginXL => EdgeInsets.all(ResponsiveHelper.wp(8));

  // Border Radius
  static double get radiusS => ResponsiveHelper.wp(2);
  static double get radiusM => ResponsiveHelper.wp(4);
  static double get radiusL => ResponsiveHelper.wp(6);
  static double get radiusXL => ResponsiveHelper.wp(8);

  // Icon Sizes
  static double get iconS => ResponsiveHelper.wp(4);
  static double get iconM => ResponsiveHelper.wp(6);
  static double get iconL => ResponsiveHelper.wp(8);
  static double get iconXL => ResponsiveHelper.wp(12);

  // Avatar Sizes
  static double get avatarS => ResponsiveHelper.wp(10);
  static double get avatarM => ResponsiveHelper.wp(15);
  static double get avatarL => ResponsiveHelper.wp(20);
  static double get avatarXL => ResponsiveHelper.wp(25);
}