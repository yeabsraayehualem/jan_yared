// lib/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  InAppWebViewController? _controller;
  double _progress = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalPolicy();
  }

  Future<void> _loadLocalPolicy() async {
    final String html = await rootBundle.loadString('assets/privacy_policy.html');
    _controller?.loadData(data: html, mimeType: 'text/html', encoding: 'utf-8');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: false,
              safeBrowsingEnabled: true,
            ),
            onWebViewCreated: (controller) => _controller = controller,
            onLoadStart: (_, __) => setState(() => _isLoading = true),
            onLoadStop: (_, __) => setState(() => _isLoading = false),
            onProgressChanged: (_, progress) =>
                setState(() => _progress = progress / 100),
          ),
          if (_isLoading || _progress < 1.0)
            LinearProgressIndicator(value: _progress == 1.0 ? null : _progress),
        ],
      ),
    );
  }
}