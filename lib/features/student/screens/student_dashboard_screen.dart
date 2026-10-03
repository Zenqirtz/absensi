import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/shared/widgets/stitch_webview.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StitchWebView(htmlPath: 'stitch/screen2_dashboard_mhs.html'),
    );
  }
}