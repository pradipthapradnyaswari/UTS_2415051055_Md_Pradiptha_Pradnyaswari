# Finote – Personal Finance Manager

Finote adalah aplikasi pengelola keuangan pribadi berbasis Flutter yang dirancang untuk membantu pengguna mencatat pemasukan dan pengeluaran, memantau kondisi keuangan, serta memahami pola transaksi secara lebih terstruktur.

## Fitur Utama

- **Dashboard:** Menampilkan saldo, total pemasukan, total pengeluaran, dan transaksi terbaru.
- **Manajemen Transaksi:** Menambahkan, melihat, mengedit, dan menghapus transaksi.
- **Analisis Keuangan:** Menampilkan ringkasan dan grafik pemasukan serta pengeluaran berdasarkan periode harian, mingguan, bulanan, dan tahunan.
- **Kategori Transaksi:** Mengelompokkan transaksi berdasarkan kategori pemasukan dan pengeluaran.
- **Pencarian dan Filter:** Mencari transaksi serta memfilter berdasarkan jenis, kategori, dan rentang tanggal.
- **Kurs Mata Uang:** Mengambil nilai tukar USD ke IDR melalui ExchangeRate-API.
- **Pengaturan Tema:** Mendukung Light, Dark, dan System dengan penyimpanan preferensi tema.

## Teknologi yang Digunakan

- Flutter dan Dart
- Supabase (PostgreSQL)
- Provider dan ChangeNotifier
- ExchangeRate-API
- Shared Preferences

## Struktur Proyek

```text
lib/
├── models/
├── providers/
├── repositories/
├── screens/
├── services/
├── utils/
├── widgets/
├── app.dart
└── main.dart
```

## Konfigurasi dan Cara Menjalankan

1. Pastikan Flutter SDK dan Android SDK sudah terpasang.
2. Clone repository:

   ```bash
   git clone https://github.com/pradipthapradnyaswari/finote.git
   cd finote
   ```

3. Instal dependensi:

   ```bash
   flutter pub get
   ```

4. Siapkan project Supabase dan tabel `transactions` sesuai struktur database aplikasi.
5. Jalankan aplikasi dengan konfigurasi Supabase:

   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
     --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
   ```

   Ganti nilai tersebut dengan URL dan Publishable Key milik project Supabase.

   Jangan memasukkan Secret Key atau Service Role Key ke dalam aplikasi Flutter maupun repository publik.

## API

Finote menggunakan ExchangeRate-API untuk memperoleh nilai tukar USD terhadap IDR.

Endpoint:

```text
https://open.er-api.com/v6/latest/USD
```

Data API diproses menjadi model Dart dan ditampilkan pada halaman Home.

Sumber: [ExchangeRate-API](https://www.exchangerate-api.com/)

## Pengujian

Jalankan pemeriksaan kode:

```bash
dart format lib
flutter analyze
flutter test
```

## Repository

[GitHub – Finote](https://github.com/pradipthapradnyaswari/finote)

## Catatan Keamanan

Konfigurasi akses database pada versi demonstrasi UTS ini ditujukan untuk pengujian aplikasi. Jangan gunakan data keuangan pribadi atau data sensitif pada konfigurasi demonstrasi yang belum dilengkapi autentikasi dan pembatasan akses per pengguna.