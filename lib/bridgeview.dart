import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class RouterWebViewScreen extends StatefulWidget {
  final String ipAddress;
  final String? username;
  final String? password;

  const RouterWebViewScreen({
    super.key,
    required this.ipAddress,
    this.username,
    this.password,
  });

  @override
  _RouterWebViewScreenState createState() => _RouterWebViewScreenState();
}

class _RouterWebViewScreenState extends State<RouterWebViewScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWebView();
  }

  Future<void> _loadWebView() async {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF5F5F5))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() {
            _isLoading = true;
            _errorMessage = null;
          }),
          onPageFinished: (url) => setState(() => _isLoading = false),
          onWebResourceError: (error) async {
            setState(() {
              _isLoading = false;
              if (error.description.contains('ERR_CLEARTEXT_NOT_PERMITTED')) {
                _errorMessage =
                'Koneksi HTTP tidak diizinkan. Coba gunakan HTTPS atau periksa konfigurasi router.';
              } else if (error.description.contains('ERR_CONNECTION_REFUSED')) {
                _errorMessage =
                'Koneksi ditolak. Pastikan IP ${widget.ipAddress} benar dan router aktif.';
              } else {
                _errorMessage = 'Error: ${error.description}';
              }
            });
            if (error.description.contains('ERR_CONNECTION_REFUSED')) {
              try {
                await _webViewController.loadRequest(
                  Uri.parse('https://${widget.ipAddress}'),
                );
              } catch (e) {
                setState(() {
                  _errorMessage =
                  'Gagal terhubung ke ${widget.ipAddress} melalui HTTPS. Pastikan IP benar.';
                });
              }
            }
          },
        ),
      );

    try {
      await _webViewController.loadRequest(
        Uri.parse('http://${widget.ipAddress}'),
        headers: {'Connection': 'close'},
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat halaman: $e';
      });
    }
  }

  void _injectCredentials() {
    if (widget.username == null || widget.password == null) return;
    _webViewController.runJavaScript('''
      var usernameInputs = document.getElementsByTagName('input');
      var passwordInput = null;
      var usernameInput = null;
      for (var i = 0; i < usernameInputs.length; i++) {
        if (usernameInputs[i].type === 'text' || usernameInputs[i].name.toLowerCase().includes('user')) {
          usernameInput = usernameInputs[i];
        }
        if (usernameInputs[i].type === 'password') {
          passwordInput = usernameInputs[i];
        }
      }
      if (usernameInput) usernameInput.value = '${widget.username}';
      if (passwordInput) passwordInput.value = '${widget.password}';
      var submit = document.querySelector('input[type="submit"], button[type="submit"], button');
      if (submit) submit.click();
    ''');
  }

  void _openWifiSettings() async {
    const url = 'package:android.settings.WIFI_SETTINGS';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka pengaturan WiFi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Text(
          'Login Router (${widget.ipAddress})',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : _errorMessage != null
          ? Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFD32F2F),
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Saran:\n- Pastikan kamu terhubung ke WiFi router yang sama.\n- Periksa IP router di Pengaturan > WiFi > Gateway.',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openWifiSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Buka Pengaturan WiFi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadWebView,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]!
                  : const Color(0xFFFFF7F7),
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : const Color(0xFFF5F5F5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: WebViewWidget(controller: _webViewController),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFFFF7F7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: widget.username != null && widget.password != null
                      ? _injectCredentials
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Coba Login',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Text(
                  'Powered by Gustyx-Power',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black54,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}