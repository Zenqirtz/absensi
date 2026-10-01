import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/shared/widgets/stitch_webview.dart';

class AttendanceRecapScreen extends StatelessWidget {
  const AttendanceRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StitchWebView(
        htmlPath: 'stitch/screen5_rekap.html',
        onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      ),
    );
  }
}