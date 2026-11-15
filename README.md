# MyPortfolio Mobile

Aplikasi mobile Flutter untuk portofolio saya (Roisul Umam).

## Fitur Saat Ini

- Halaman utama (`lib/menu.dart`, `StatelessWidget`) dengan 3 `InfoCard`: NPM, Name, dan Class.
- 3 tombol aksi `ItemCard` dengan warna latar berbeda: **Lihat Proyek** (biru), **Tambah Proyek** (hijau), dan **Logout** (merah).
- `SnackBar` bertuliskan "Kamu telah menekan tombol [Nama Tombol]!" saat tombol ditekan.

## Struktur Proyek

- `lib/main.dart`: titik masuk aplikasi dan `MaterialApp` (tema dan halaman awal).
- `lib/menu.dart`: `MyHomePage`, `InfoCard`, `ItemCard`, dan model `ItemHomepage` (nama, ikon, warna).
- `test/widget_test.dart`: widget test untuk halaman utama.

## Cara Menjalankan

1. Pasang Flutter SDK dan siapkan emulator atau perangkat.
2. Clone repositori ini, lalu jalankan:
   ```bash
   flutter pub get
   flutter run
   ```
3. Cek kualitas kode dan test:
   ```bash
   flutter analyze
   flutter test
   ```

## Progres Mingguan

- **Tutorial 08**: setup Flutter, memisahkan `menu.dart` dari `main.dart`, `MyHomePage` menjadi `StatelessWidget`, dan membuat `InfoCard` serta `ItemCard`.
- **Tugas 7**: identitas pemilik portofolio, 3 tombol aksi dengan warna berbeda lewat atribut `color` di `ItemHomepage`, SnackBar interaktif, dan `flutter analyze` bersih.

### Tugas 7

1. Widget tree ituu kayak susunan widget bersarang yang ngebentuk seluruh UI nya si Flutter. Setiap widget (kecuali root yak) punya satu parent, dan parent bisa punya satu `child` atauu banyak `children`. Di aplikasi ini strukturnya kira-kira: `MyApp` → `MaterialApp` → `MyHomePage` → `Scaffold` → `Padding` → `Column` → (`Row` yang isinya 3 `InfoCard`, trus `GridView` yg isinya 3 `ItemCard`). Hubungan parent-child itu kerjanya kayak ginilah kira kira: parent ngasih batasan ukuran (*constraints*) ke child, child nentuin nih ukurannya sendiri dalam batasan itu, trus parent nentuin posisinya. Kalau parent di-rebuild, child-nya ikut direbuild. Widget di bawah juga bisa ngambil data dari ancestor, misal tema dari `MaterialApp`.

2. Widget yang dipake:
   - `MyApp`, `MyHomePage`, `InfoCard`, `ItemCard`: widget buatan akuu sendiri buat aplikasi, main page, identity card, dan action card button.
   - `MaterialApp`: root aplikasi yang ngatur tema, judul, dan page awal.
   - `Scaffold`: kerangka halaman (AppBar, body, dan tempat SnackBar muncul).
   - `AppBar`: bar judul di bagian atas.
   - `Padding`: ngasih jarak di sekeliling child.
   - `Column` dan `Row`: nyusun widget secara vertikal dan horizontal.
   - `Center`: ngecenter-in si child.
   - `SizedBox`: ngasih jarak kosong antar-widget.
   - `GridView.count`: nampilin tombol dalam kisi 3 kolom.
   - `Card`: card dengan shadow buat `InfoCard`.
   - `Container`: wadah dengan padding dan lebar tertentu.
   - `Text`: nampilin teks.
   - `Icon`: nampilin icon di tombol.
   - `Material`: dasar Material berwarna dan ujungnya yang rounded buat `ItemCard`.
   - `InkWell`: area yang bisa di-press, trus ada efek percikannya juga.
   - `SnackBar` dan `ScaffoldMessenger`: nampilin dan ngelola short massage di bagian bawah layar.

3. `MaterialApp` itu widget yang ngebungkus aplikasi dengan Material Design. Dia ngatur `title`, `theme` (kalo di sini `ColorScheme` dari seed indigo), page awal (`home`), serta navigasi dan lokalisasi. Dia juga nyedia-in hal-hal yang dibutuhkan widget di bawahnya, kayak `Theme`, `MediaQuery`, `Navigator`, dan `ScaffoldMessenger`. Karena itulahh `MaterialApp` dipake jadi root: tanpa itu, `Scaffold`, `AppBar`, dan SnackBar gapunya konteks Material dan bisa aja error.

4. `StatelessWidget` itu gapunya state internal yang berubah. Tampilannya cuma bergantung pada parameter yang diterima saat dibuat, jadi cuma draw ulang kalau parent-nya ngasih data baru. `StatefulWidget` punya objek `State` yang nyimpen data dinamis, dan tampilan diupdate lewat `setState()`. Pilih `StatelessWidget` kalau UI ga berubah sendiri, kayak `MyHomePage`, `InfoCard`, dan `ItemCard` di proyek ini (NPM, nama, dan daftar tombol bersifat tetap). Pilih `StatefulWidget` kalo ada data yang berubah pas aplikasi running, misal isian form, counter, checkbox, animasi, atau data yang dimuat dari server.

5. `BuildContext` adalahh penunjuk lokasi sebuah widget di dalam widget tree. Lewat `context`, widget bisa nyari ancestor atau data bersama di atasnya. Parameter ini ada di setiap method `build(BuildContext context)`. Di proyek ini, `Theme.of(context)` dipake buat warna AppBar, `MediaQuery.of(context)` untuk menghitung lebar `InfoCard`, dan `ScaffoldMessenger.of(context)` untuk menampilkan SnackBar saat kartu di-press. Context harus berada di bawah widget yang dicari, makanya `ItemCard` bisa nemuin `ScaffoldMessenger` punyanya si `MaterialApp`.

6. *Hot reload* masukin perubahan kode ke aplikasi yang sedang running trus di rebuild widget tree tanpa ngilangin state, jadi perubahan tampilan keliatan hampir sebentar. *Hot restart* ngejalanin ulang aplikasi dari `main()` dan ngereset semua state, tapi tetep lebih cepet dari full build. Hot reload gacukup kalo aku ngubah `main()`, value awal variabel global/static, atau logika `initState`, karena kode itu cuma dijalanin sekali di awal, jadi perlu hot restart. Full restart (stop lalu run ulang) diperlukan kalo aku ngubah kode native (Gradle, `AndroidManifest.xml`, konfigurasi iOS) atau nambah plugin baru di `pubspec.yaml`.

## AI Disclosure Tugas 7

AI (Claude) ngebantu aku buat memandu Tugas 7 pada proyek `myportofolio_mobile`. Aku ngasih tau AI perihal tugas 7 ini lalu meminta dia buat memeriksa apa saja yang kurang di proyek aku sebelum tugas 7 dikerjakan.

### Cakupan Bantuan AI

- AI memeriksa kode yang sudah ada dan menemukan bagian yang belum memenuhi instruksi, yaitu warna tombol masih seragam.
- AI menyarankanku untuk menambahkan atribut `color` pada model `ItemHomepage`.
- AI mengingatkanku untuk mengganti test bawaan (counter) dengan widget test untuk halaman utama, warna tombol, dan SnackBar.
- AI membantu menyusun pesan commit `=)`.

### Keterbatasan AI yang Diidentifikasi

- **AI gabisa menjalankan Flutter.** Lingkungan AI gapunya Flutter SDK, jadi `flutter analyze`, `flutter test`, dan `flutter run` tidak pernah dijalankan olehnya. Hasilnya hanya berdasarkan pembacaan kode, dan aku harus memverifikasinya sendiri.
- **AI galiat tampilan di perangkat asli**, sehingga soal tata letak (misalnya teks panjang di kartu) tidak bisa ia nilai.

### Penyesuaian Manual yang Dilakukan

- Aku menjalankan `flutter analyze` dan `flutter test`, lalu memastikan hasilnya bersih dan lulus.
- Aku menjalankan aplikasi di emulator/perangkat untuk memastikan warna tiap tombol berbeda dan SnackBar muncul sesuai nama tombol.
- Aku memeriksa ulang data NPM, nama, dan kelas, lalu memahami dan memeriksa kode dari AI sebelum di-commit secara bertahap.