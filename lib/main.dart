import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'bridgeview.dart';
import 'help_screen.dart';
import 'welcome_popup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RouterSetApp());
}

class RouterSetApp extends StatefulWidget {
  const RouterSetApp({super.key});

  @override
  _RouterSetAppState createState() => _RouterSetAppState();
}

class _RouterSetAppState extends State<RouterSetApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isDarkMode = SharedPreferences.getInstance().then((prefs) {
            return prefs.getBool('isDarkMode') ??
                (MediaQuery.of(context).platformBrightness == Brightness.dark);
          }) as bool;
        });
      }
    });

    return MaterialApp(
      title: 'RouterSet',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.transparent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.transparent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardColor: Colors.grey[800],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white54),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: BrandSelectionScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class BrandSelectionScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const BrandSelectionScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  _BrandSelectionScreenState createState() => _BrandSelectionScreenState();
}

class _BrandSelectionScreenState extends State<BrandSelectionScreen> {
  String _selectedBrand = 'TP-Link';
  String _ipAddress = '';
  bool _isVerifying = true;
  String? _ssid;
  String? _netmask;
  bool _isWifiConnected = false;
  bool _isLocationPermissionGranted = false;
  bool _isIpValid = false;
  TextEditingController _ipController = TextEditingController();

  final Map<String, String> _brandDefaultIPs = {
    'TP-Link': '192.168.0.1',
    'D-Link': '192.168.0.1',
    'Tenda': '192.168.0.1',
    'Fiberhome': '192.168.1.1',
    'Huawei': '192.168.3.1',
    'ZTE': '192.168.2.1',
    'Indihome': '192.168.1.1',
  };

  final Map<String, String> _brandLogos = {
    'TP-Link': 'assets/tplink.png',
    'D-Link': 'assets/d-link.png',
    'Tenda': 'assets/tenda.png',
    'Fiberhome': 'assets/fiberhome.png',
    'Huawei': 'assets/huawei.png',
    'ZTE': 'assets/zte.png',
    'Indihome': 'assets/indihome.png',
  };

  @override
  void initState() {
    super.initState();
    _loadLastIp();
    _checkPermissionsAndConnection();
    _showWelcomePopup();
  }

  Future<void> _loadLastIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipAddress = prefs.getString('lastIp_$_selectedBrand') ?? '';
      _ipController.text = _ipAddress;
    });
  }

  Future<void> _saveLastIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastIp_$_selectedBrand', ip);
  }

  Future<void> _showWelcomePopup() async {
    if (await WelcomePopup.shouldShowPopup()) {
      WelcomePopup.show(context);
    }
  }

  Future<void> _checkPermissionsAndConnection() async {
    setState(() => _isVerifying = true);

    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
      if (locationStatus.isPermanentlyDenied) {
        _showPermissionWarning();
      }
    }
    setState(() => _isLocationPermissionGranted = locationStatus.isGranted);

    await Future.delayed(const Duration(milliseconds: 500));
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      setState(() => _isWifiConnected = true);
      if (_isLocationPermissionGranted) {
        final networkInfo = NetworkInfo();
        _ssid = await networkInfo.getWifiName();
        _netmask = "Tidak tersedia";
      } else {
        _ssid = "Izin lokasi diperlukan";
        _netmask = "Tidak tersedia";
      }
    } else {
      setState(() => _isWifiConnected = false);
      _ssid = "Tidak terhubung";
      _netmask = "Tidak tersedia";
      _showCellularWarning();
    }

    await Future.delayed(const Duration(milliseconds: 500));
    final ipToValidate = _ipAddress.isEmpty ? _brandDefaultIPs[_selectedBrand]! : _ipAddress;
    _isIpValid = _validateIp(ipToValidate);

    setState(() => _isVerifying = false);
  }

  bool _validateIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    for (var part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  Future<void> _detectIp() async {
    setState(() => _isVerifying = true);
    try {
      final networkInfo = NetworkInfo();
      final gatewayIp = await networkInfo.getWifiGatewayIP();
      if (gatewayIp != null && _validateIp(gatewayIp)) {
        setState(() {
          _ipAddress = gatewayIp;
          _ipController.text = gatewayIp;
          _isIpValid = true;
        });
        await _saveLastIp(gatewayIp);
      } else {
        _showIpDetectionError();
      }
    } catch (e) {
      _showIpDetectionError();
    }
    setState(() => _isVerifying = false);
  }

  void _showIpDetectionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : const Color(0xFFF5F5F5),
        title: const Text(
          'Gagal Mendeteksi IP',
          style: TextStyle(color: Color(0xFFD32F2F)),
        ),
        content: const Text(
          'Tidak dapat mendeteksi IP router. Silakan masukkan IP secara manual.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCellularWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : const Color(0xFFF5F5F5),
        title: const Text(
          'Peringatan',
          style: TextStyle(color: Color(0xFFD32F2F)),
        ),
        content: const Text(
          'Aplikasi ini hanya dapat digunakan dengan koneksi WiFi. Silakan sambungkan ke WiFi router Anda.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkPermissionsAndConnection();
            },
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : const Color(0xFFF5F5F5),
        title: const Text(
          'Izin Diperlukan',
          style: TextStyle(color: Color(0xFFD32F2F)),
        ),
        content: const Text(
          'Aplikasi ini memerlukan izin lokasi untuk mendeteksi SSID WiFi. Silakan aktifkan di pengaturan.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text(
              'Buka Pengaturan',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToWebView() {
    if (_isWifiConnected && _isIpValid) {
      final ipToUse = _ipAddress.isEmpty ? _brandDefaultIPs[_selectedBrand]! : _ipAddress;
      _saveLastIp(ipToUse);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouterWebViewScreen(
            ipAddress: ipToUse,
            username: null,
            password: null,
          ),
        ),
      );
    } else if (!_isWifiConnected) {
      _showCellularWarning();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : const Color(0xFFF5F5F5),
          title: const Text(
            'IP Tidak Valid',
            style: TextStyle(color: Color(0xFFD32F2F)),
          ),
          content: const Text(
            'Silakan masukkan IP yang valid atau gunakan tombol Deteksi IP.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isVerifying
          ? Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SpinKitFadingCircle(
                color: Color(0xFFD32F2F),
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                _ssid == null
                    ? 'Mendeteksi SSID...'
                    : 'Memvalidasi IP...',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'RouterSet',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                            color: const Color(0xFFD32F2F),
                          ),
                          onPressed: widget.onToggleTheme,
                        ),
                        Icon(
                          _isWifiConnected ? Icons.wifi : Icons.wifi_off,
                          color: _isWifiConnected ? const Color(0xFFD32F2F) : Colors.grey,
                          size: 28,
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 8),
                Text(
                  _isWifiConnected
                      ? 'Terhubung ke: ${_ssid ?? "Unknown"}'
                      : 'Tidak terhubung ke WiFi',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 24),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pilih Brand Router',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.help_outline,
                                color: Color(0xFFD32F2F),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HelpScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: _brandDefaultIPs.keys.map((brand) {
                            final logoPath = _brandLogos[brand];
                            if (logoPath == null) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedBrand = brand;
                                    _loadLastIp();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selectedBrand == brand
                                          ? const Color(0xFFD32F2F)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.router,
                                    size: 50,
                                    color: Color(0xFFD32F2F),
                                  ),
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedBrand = brand;
                                  _loadLastIp();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedBrand == brand
                                        ? const Color(0xFFD32F2F)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(
                                  logoPath,
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.router,
                                      size: 50,
                                      color: Color(0xFFD32F2F),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Router IP (kosongkan untuk default)',
                                  labelStyle: const TextStyle(color: Colors.black54),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[700]
                                      : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD32F2F), width: 2),
                                  ),
                                ),
                                controller: _ipController,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                keyboardType: TextInputType.url,
                                onChanged: (value) {
                                  setState(() {
                                    _ipAddress = value;
                                    _isIpValid = _validateIp(value.isEmpty
                                        ? _brandDefaultIPs[_selectedBrand]!
                                        : value);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Color(0xFFD32F2F),
                              ),
                              onPressed: _detectIp,
                              tooltip: 'Deteksi IP Otomatis',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(duration: 600.ms, begin: 0.2, end: 0),
                const Spacer(),
                Container(
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
                    onPressed: _navigateToWebView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Lanjut',
                      style: TextStyle(
                          fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Powered by Gustyx-Power',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}