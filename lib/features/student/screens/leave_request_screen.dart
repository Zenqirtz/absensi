import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/shared/widgets/stitch_webview.dart';

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StitchWebView(
        htmlPath: 'stitch/screen6_izin_sakit.html',
        onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      ),
    );
  }
}