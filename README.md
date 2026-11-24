# Cuaca Minimal

Aplikasi Flutter sederhana: **GPS** menentukan lokasi, lalu **Open-Meteo API** menyediakan cuaca saat ini dan prakiraan 7 hari.
Tema: satu warna utama (teal `#0F766E`) + putih/hitam.

## Kondisi awal
Project baru, dibuat untuk Tugas 2 (TI253304). Tidak melanjutkan project sebelumnya.

## Struktur (MVVM + Repository + Service)
```
lib/
  main.dart                      titik masuk
  app/theme.dart                 warna & tema
  models/weather.dart            model data + fromJson
  services/weather_service.dart  HTTP ke Open-Meteo
  services/location_service.dart GPS + izin
  repositories/                  menjembatani service -> model
  viewmodels/                    state: loading / success / error / izin ditolak
  views/home_page.dart           UI
test/                            test parsing JSON & ViewModel (service palsu)
android/, ios/                   konfigurasi platform (izin lokasi sudah ditambahkan)
```

## Instalasi dan cara menjalankan
Prasyarat: Flutter SDK (Dart ^3.3).
1. `flutter pub get`
2. Jalankan: `flutter run` (pilih perangkat), atau `flutter run -d chrome` untuk web.
3. Test: `flutter test`
4. Analisis kode: `flutter analyze`

## Izin yang dideklarasikan
| Platform | File | Isi |
|---|---|---|
| Android | `android/app/src/main/AndroidManifest.xml` | `INTERNET`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` |
| iOS | `ios/Runner/Info.plist` | `NSLocationWhenInUseUsageDescription` (teks alasan izin lokasi) |

Izin diminta saat layar utama memuat cuaca. Bila ditolak, aplikasi menampilkan pesan dan alternatif (Coba lagi, Buka pengaturan, Pakai lokasi Denpasar), tidak crash. Catatan: tombol "Buka pengaturan" hanya berfungsi di Android/iOS, tidak di web.

## API
- Open-Meteo Forecast: `https://api.open-meteo.com/v1/forecast`
- Tanpa API key, jadi tidak ada kredensial di kode/Git dan dosen tidak memerlukan key uji.
- Lisensi data CC BY 4.0 (atribusi ditampilkan di aplikasi).

## Integrasi GPS + API
1. Aplikasi meminta izin lokasi saat dibuka.
2. Koordinat dari GPS dikirim sebagai `latitude` & `longitude` ke Open-Meteo.
3. Respons di-parse (`fromJson`) dan ditampilkan sebagai kartu cuaca + daftar 7 hari.

## Penanganan error
| Kondisi | Perilaku |
|---|---|
| Tanpa internet / timeout / 4xx / 5xx / data rusak | Pesan ramah + tombol **Coba lagi** |
| Izin lokasi ditolak | Pesan + tombol **Coba lagi** dan **Pakai lokasi Denpasar** |
| Ditolak permanen | Tambahan tombol **Buka pengaturan** |
| GPS mati | Pesan agar mengaktifkan GPS |

## Sumber dan alat bantu
Dokumentasi Open-Meteo (open-meteo.com), paket `http` dan `geolocator`. Kode awal dibantu Claude (AI); rincian prompt ada pada Lampiran AI Tugas 2.
