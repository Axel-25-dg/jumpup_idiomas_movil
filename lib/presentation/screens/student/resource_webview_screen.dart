import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:jumpup_app/core/config/app_config.dart';

class ResourceWebViewScreen extends StatefulWidget {
  const ResourceWebViewScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<ResourceWebViewScreen> createState() => _ResourceWebViewScreenState();
}

class _ResourceWebViewScreenState extends State<ResourceWebViewScreen> {
  late final WebViewController _controller;
  late final String _normalizedUrl;
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _normalizedUrl = _normalizeUrl(widget.url);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (_) async {
            if (!mounted) return;
            final canBack = await _controller.canGoBack();
            final canForward = await _controller.canGoForward();
            setState(() {
              _isLoading = false;
              _canGoBack = canBack;
              _canGoForward = canForward;
            });
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = error.description;
              });
            }
          },
        ),
      );

    final uriToLoad = Uri.tryParse(_normalizedUrl);
    if (uriToLoad == null || uriToLoad.scheme.isEmpty) {
      _hasError = true;
      _isLoading = false;
      _errorMessage = 'URL inválida: ${widget.url}';
    } else {
      _controller.loadRequest(uriToLoad);
    }
  }

  Future<bool> _handleWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.tryParse(_normalizedUrl);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL no válida para abrir en navegador')),
      );
      return;
    }

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede abrir la URL en el navegador')),
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _normalizeUrl(String rawUrl) {
    var url = rawUrl.trim();
    if (url.isEmpty) return url;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = AppConfig.resolveImageUrl(url);
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://${url.replaceFirst(RegExp(r'^/+'), '')}';
    }

    final lower = url.toLowerCase();
    if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.ppt') ||
        lower.endsWith('.pptx')) {
      return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}';
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: _canGoBack ? () => _controller.goBack() : null,
              tooltip: 'Atrás',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _canGoForward ? () => _controller.goForward() : null,
              tooltip: 'Adelante',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
              tooltip: 'Recargar',
            ),
          ],
        ),
        body: Stack(
          children: [
            if (!_hasError) WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'No se pudo cargar el recurso.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Abrir en navegador'),
                        onPressed: _openInExternalBrowser,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
