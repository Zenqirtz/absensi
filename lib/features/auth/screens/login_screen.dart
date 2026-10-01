import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/shared/widgets/stitch_webview.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StitchWebView(
        htmlPath: 'stitch/screen1_login.html',
        onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      ),
    );
  }
}
