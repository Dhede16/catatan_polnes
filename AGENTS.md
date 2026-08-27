# AGENTS.md — catatan_polnes
  
## Perintah Verifikasi
Jalankan setelah setiap perubahan; jangan menyatakan pekerjaan
selesai sebelum ketiganya lulus:
    dart format --set-exit-if-changed .
    flutter analyze
    flutter test
  
## Konteks Proyek
Aplikasi catatan untuk praktikum Pemrograman Perangkat Bergerak,
Politeknik Negeri Samarinda. Flutter 3.44, Dart 3.12.
  
## Konvensi Kode
- Nama berkas snake_case; nama kelas PascalCase.
- DILARANG memakai print(); gunakan debugPrint() saat pengembangan.
- DILARANG menulis kunci API atau kredensial di dalam kode.
- Ikuti aturan pada analysis_options.yaml.
  
## Batasan Perubahan
- Jangan menyentuh direktori android/ dan web/ kecuali diminta.
- Jangan menambah dependensi tanpa persetujuan.