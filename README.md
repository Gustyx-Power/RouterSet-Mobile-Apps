# RouterSet
- Developer : GustyxPower(Gusti)

RouterSet adalah aplikasi Flutter yang dirancang untuk mempermudah konfigurasi dan pengelolaan router melalui antarmuka web. Aplikasi ini cocok untuk pengguna yang sering bekerja dengan perangkat jaringan, terutama mereka yang ingin mengakses panel admin router dengan cepat dan efisien.

## Fitur Utama

- **Pemilihan Brand Router**: Pengguna dapat memilih merek router (seperti TP-Link, D-Link, Tenda, Fiberhome, Huawei, ZTE, dan Indihome) untuk menyesuaikan IP default yang digunakan.
- **Input IP Manual**: Memungkinkan pengguna memasukkan alamat IP router secara manual jika berbeda dari default.
- **Deteksi Koneksi WiFi**: Aplikasi memeriksa status koneksi WiFi dan menampilkan SSID jaringan yang terhubung (dengan izin lokasi).
- **Navigasi ke WebView**: Mengarahkan pengguna ke halaman admin router melalui WebView berdasarkan IP yang dipilih atau dimasukkan.
- **Riwayat IP**: Menyimpan riwayat IP yang pernah digunakan per merek router, dapat diakses melalui menu dropdown untuk kemudahan pemilihan ulang.
- **Tema Gelap/Terang**: Mendukung pengaturan tema yang dapat diubah oleh pengguna untuk kenyamanan visual.
- **Screenshot WebView**: Memungkinkan pengguna mengambil tangkapan layar dari halaman admin router yang ditampilkan di WebView dan menyimpannya ke galeri.

## Persyaratan

- **Flutter SDK**: Pastikan Flutter sudah terinstal (versi terbaru disarankan).
- **Dependencies**:
  - `connectivity_plus`
  - `network_info_plus`
  - `permission_handler`
  - `shared_preferences`
  - `flutter_spinkit`
  - `flutter_animate`
  - `webview_flutter`
  - `screenshot`
- **Izin**: Aplikasi memerlukan izin lokasi (untuk mendeteksi SSID) dan penyimpanan (untuk menyimpan screenshot).

## Penggunaan
- Buka aplikasi RouterSet.
- Pilih merek router dari daftar yang tersedia.
- Masukkan IP router secara manual atau gunakan IP default.
- Gunakan tombol "Riwayat IP" untuk memilih IP yang pernah digunakan sebelumnya.
- Klik tombol "Lanjut" untuk masuk ke halaman admin router melalui WebView.
- Untuk mengganti tema, klik ikon matahari/bulan di pojok kanan atas.

## Catatan
- Pastikan perangkat terhubung ke WiFi router untuk menggunakan aplikasi.
- Berikan izin lokasi untuk mendeteksi SSID jaringan.
