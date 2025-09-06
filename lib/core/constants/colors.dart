import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color maritimeBlue = Color(0xFF003F7F);        // Primary Maritime Blue
  static const Color maritimeLightBlue = Color(0xFF0066CC);   // Lighter variant
  static const Color maritimeDarkBlue = Color(0xFF002F5F);    // Darker variant

  // Supporting Colors (inspired by maritime/logistics)
  static const Color oceanTeal = Color(0xFF006B7D);         // Ocean depth
  static const Color skyBlue = Color(0xFF4A90E2);           // Clear sky
  static const Color containerOrange = Color(0xFFFF6B35);   // Container accent
  static const Color portGrey = Color(0xFF8E9AAF);          // Industrial grey

  // Status Colors (Logistics specific)
  // Các Status của order:
  // InProgress (Đang xử lý)
  // PickedUp (Đã lấy hàng)
  // InTransit (Đang vận chuyển)
  // Delivered (Đã giao)
  // Completed (Hoàn thành)
  // Cancelled (Đã hủy)
  // FailedDelivery (Giao thất bại)
  static const Color statusInTransit = Color(0xFF0066CC);   // Blue - moving
  static const Color statusAtPort = Color(0xFF006B7D);      // Teal - at location
  static const Color statusDelivered = Color(0xFF28A745);   // Green - completed
  static const Color statusDelayed = Color(0xFFFF6B35);     // Orange - warning
  static const Color statusError = Color(0xFFDC3545);       // Red - problem

  // Background Colors
  static const Color primaryBackground = Color(0xFFF8FAFB); // Very light blue-grey
  static const Color cardBackground = Color(0xFFFFFFFF);    // Pure white
  static const Color sectionBackground = Color(0xFFF1F4F7); // Light section divider

  // Text Colors
  static const Color primaryText = Color(0xFF1A2B3D);       // Dark blue-grey
  static const Color secondaryText = Color(0xFF5A6C7D);     // Medium grey
  static const Color hintText = Color(0xFF8E9AAF);          // Light grey
  static const Color onPrimaryText = Color(0xFFFFFFFF);     // White on blue

  // Gradients (Maritime inspired)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [maritimeBlue, maritimeLightBlue],
  );

  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyBlue, oceanTeal],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFB)],
  );

  // Shadows (Subtle, professional)
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x08003F7F),  // Very subtle blue shadow
    blurRadius: 12,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const BoxShadow elevatedShadow = BoxShadow(
    color: Color(0x12003F7F),  // Slightly stronger for elevated elements
    blurRadius: 16,
    offset: Offset(0, 6),
    spreadRadius: 0,
  );
}