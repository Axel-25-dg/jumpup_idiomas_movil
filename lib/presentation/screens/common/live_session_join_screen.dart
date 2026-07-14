import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LiveSessionJoinScreen extends StatefulWidget {
  const LiveSessionJoinScreen({
    super.key,
    required this.meetingUrl,
    required this.title,
  });

  final String meetingUrl;
  final String title;

  @override
  State<LiveSessionJoinScreen> createState() => _LiveSessionJoinScreenState();
}

class _LiveSessionJoinScreenState extends State<LiveSessionJoinScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      );
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final uri = _normalizeUrl(widget.meetingUrl);
    if (uri == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }
    await _controller.loadRequest(uri);
  }

  Uri? _normalizeUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final parsed = Uri.tryParse(value);
    if (parsed == null) return null;
    if (parsed.hasScheme) {
      return parsed;
    }
    return Uri.parse('https://$value');
  }

  @override
  Widget build(BuildContext context) {
    final uri = _normalizeUrl(widget.meetingUrl);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.isNotEmpty ? widget.title : 'Sala de clase'),
        backgroundColor: const Color(0xFF0F0E1A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: () async {
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            tooltip: 'Abrir en navegador',
          ),
        ],
      ),
      body: uri == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_rounded, size: 64, color: Colors.white54),
                    const SizedBox(height: 16),
                    Text(
                      'La sala aún no tiene un enlace disponible',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El profesor puede agregar un enlace de reunión para habilitar la entrada.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                  ),
              ],
            ),
    );
  }
}
