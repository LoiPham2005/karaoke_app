import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📏 App Dimensions — Semantic responsive values
class AppDimensions {
  AppDimensions._();

  // ─── Common Spacing ───
  static double get padding => 16.r; // Padding chuẩn cho màn hình/card
  static double get margin => 16.r; // Margin chuẩn
  static double get gap => 12.r; // Khoảng cách giữa các phần tử con
  static double get gapSmall => 8.r; // Khoảng cách nhỏ

  // ─── Border Radius ───
  static double get radius => 12.r; // Bo góc chuẩn
  static double get radiusSmall => 8.r; // Bo góc nhẹ
  static double get radiusLarge => 20.r; // Bo góc mạnh
  static double get circle => 999.r; // Bo tròn tuyệt đối

  // ─── Widget Sizes ───
  static double get icon => 24.r; // Kích thước icon chuẩn
  static double get iconSmall => 20.r; // Kích thước icon nhỏ
  static double get buttonHeight => 48.r; // Chiều cao button chuẩn

  // ─── Elevation ───
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;

  // ─── Screen Breakpoints ───
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;
}
