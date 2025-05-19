import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        title: const Text(
          'Panduan Pengguna',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildHelpItem(
                context,
                '1. Cara menemukan IP router',
                'Buka Pengaturan > WiFi di perangkat Anda, lalu lihat alamat "Gateway". Itu biasanya adalah IP router (misalnya, 192.168.0.1).',
              ),
              _buildHelpItem(
                context,
                '2. Pastikan terhubung ke WiFi router',
                'Aplikasi hanya bisa digunakan jika perangkat terhubung ke WiFi router yang sama. Periksa koneksi WiFi Anda sebelum melanjutkan.',
              ),
              _buildHelpItem(
                context,
                '3. Jika gagal terhubung',
                'Coba restart router Anda, periksa kembali IP yang dimasukkan, atau pastikan tidak ada pengaturan keamanan yang memblokir akses.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, String title, String description) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
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
    );
  }
}