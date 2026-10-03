// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

class StitchWebView extends StatefulWidget {
  final String htmlPath;
  final void Function(String route)? onNavigate;

  const StitchWebView({
    super.key,
    required this.htmlPath,
    this.onNavigate,
  });

  @override
  State<StitchWebView> createState() => _StitchWebViewState();
}

final _registeredViews = <String>{};

class _StitchWebViewState extends State<StitchWebView> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'stitch-iframe-${widget.htmlPath.hashCode}';

    if (!_registeredViews.contains(_viewId)) {
      _registeredViews.add(_viewId);
      ui_web.platformViewRegistry.registerViewFactory(_viewId, (int id) {
        final iframe = html.IFrameElement()
          ..src = widget.htmlPath
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        return iframe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
