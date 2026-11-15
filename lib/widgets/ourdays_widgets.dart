import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class AppColors {
  static const brown = Color(0xFF805B48);
  static const latte = Color(0xFFB88D75);
  static const pink = Color(0xFFE9BFC6);
  static const softPink = Color(0xFFF6E5E2);
  static const cream = Color(0xFFFFF9F5);
  static const ink = Color(0xFF45362F);
  static const muted = Color(0xFF927F75);
  static const line = Color(0xFFF0E6DF);
  static const sage = Color(0xFF788B73);
}

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    required this.child,
    this.maxWidth = 760,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.action,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 29,
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
                letterSpacing: -0.8,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 5),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
          ],
        ),
      ),
      ?action,
    ],
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      ?trailing,
    ],
  );
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.background = Colors.white,
    this.foreground = AppColors.brown,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      fixedSize: const Size(44, 44),
    ),
    icon: Icon(icon, size: 20),
  );
}

String formatDate(DateTime date, {bool includeYear = false}) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}${includeYear ? ', ${date.year}' : ''}';
}

String formatWeekday(DateTime date) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return weekdays[date.weekday - 1];
}

String formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  return '$hour:${date.minute.toString().padLeft(2, '0')} ${date.hour < 12 ? 'AM' : 'PM'}';
}

String formatRupiah(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return 'Rp $buffer';
}

Uint8List? decodePhoto(String data) {
  if (data.isEmpty) return null;
  try {
    return base64Decode(data);
  } on FormatException {
    return null;
  }
}

Widget memoryImage({
  required String data,
  required double height,
  double? width,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(18)),
  Widget? placeholder,
}) {
  final bytes = decodePhoto(data);
  return ClipRRect(
    borderRadius: borderRadius,
    child: bytes == null
        ? SizedBox(
            height: height,
            width: width,
            child:
                placeholder ??
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.softPink, Color(0xFFE4CEC1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_camera_back_rounded,
                    color: AppColors.brown,
                    size: 32,
                  ),
                ),
          )
        : Image.memory(
            bytes,
            height: height,
            width: width,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              height: height,
              width: width,
              color: AppColors.softPink,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
  );
}

void showStateError(BuildContext context, String? error) {
  if (error == null || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(error)));
}
