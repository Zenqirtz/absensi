import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/shared/widgets/stitch_webview.dart';

class AttendanceJoinScreen extends StatelessWidget {
  const AttendanceJoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StitchWebView(htmlPath: 'stitch/screen3_absen.html'),
    );
  }
}