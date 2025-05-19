import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'bridgeview.dart';

class CredentialSelectionScreen extends StatefulWidget {
  final String selectedBrand;
  final String ipAddress;

  const CredentialSelectionScreen({
    super.key,
    required this.selectedBrand,
    required this.ipAddress,
  });

  @override
  _CredentialSelectionScreenState createState() => _CredentialSelectionScreenState();
}

class _CredentialSelectionScreenState extends State<CredentialSelectionScreen> {
  String? _selectedUsername;
  String? _selectedPassword;

  // Daftar brand dan kombinasi username/password default
  final Map<String, List<Map<String, String>>> _brandCredentials = {
    'TP-Link': [
      {'username': 'admin', 'password': 'admin'},
      {'username': '', 'password': 'admin'},
      {'username': '', 'password': 'gust717'},
      {'username': 'admin', 'password': 'password'},
      {'username': 'admin', 'password': ''},
    ],
    'D-Link': [
      {'username': 'admin', 'password': 'admin'},
      {'username': 'admin', 'password': ''},
      {'username': 'user', 'password': 'user'},
      {'username': '', 'password': 'admin'},
    ],
    'Tenda': [
      {'username': 'admin', 'password': 'admin'},
      {'username': '', 'password': 'admin'},
      {'username': 'admin', 'password': ''},
    ],
    'Fiberhome': [
      {'username': 'admin', 'password': 'admin'},
      {'username': 'user', 'password': 'user'},
      {'username': 'admin', 'password': 'fiberhome'},
      {'username': 'admin', 'password': 'admin1234'},
    ],
    'Huawei': [
      {'username': 'admin', 'password': 'admin'},
      {'username': 'telecomadmin', 'password': 'admintelecom'},
      {'username': 'root', 'password': 'admin'},
      {'username': 'admin', 'password': 'Huawei123'},
    ],
    'ZTE': [
      {'username': 'admin', 'password': 'admin'},
      {'username': 'user', 'password': 'user'},
      {'username': 'admin', 'password': 'zte123'},
      {'username': '', 'password': 'admin'},
    ],
    'Indihome': [
      {'username': 'admin', 'password': 'admin'},
      {'username': 'user', 'password': 'user1234'},
      {'username': 'admin', 'password': 'admin123'},
      {'username': 'support', 'password': 'support'},
    ],
  };

  // Navigasi ke WebView untuk login
  void _navigateToWebView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouterWebViewScreen(
          ipAddress: widget.ipAddress,
          username: _selectedUsername,
          password: _selectedPassword,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final credentials = _brandCredentials[widget.selectedBrand] ?? [];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7F7), Color(0xFFF5F5F5)],
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
                const Text(
                  'Pilih Kredensial',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F),
                  ),
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 8),
                Text(
                  'Brand: ${widget.selectedBrand}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: credentials.length,
                    itemBuilder: (context, index) {
                      final credential = credentials[index];
                      final username = credential['username'] ?? '';
                      final password = credential['password'] ?? '';
                      final isSelected = _selectedUsername == username && _selectedPassword == password;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFD32F2F) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text(
                            'Username: ${username.isEmpty ? "(none)" : username}',
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFD32F2F) : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Password: ${password.isEmpty ? "(none)" : password}',
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFD32F2F) : Colors.black54,
                            ),
                          ),
                          onTap: () => setState(() {
                            _selectedUsername = username;
                            _selectedPassword = password;
                          }),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: (index * 100).ms);
                    },
                  ),
                ),
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
                    onPressed: _selectedUsername != null && _selectedPassword != null
                        ? _navigateToWebView
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF7F7), Color(0xFFD32F2F)],
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
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Powered by Gustyx-Power',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}