# MyPortfolio Mobile

Aplikasi mobile Flutter untuk portofolio saya (Roisul Umam).

## Fitur Saat Ini

- Halaman utama (`lib/screens/menu.dart`, `StatelessWidget`) dengan 3 `InfoCard`: NPM, Name, dan Class.
- 4 tombol aksi `ItemCard` dengan warna latar berbeda: **Lihat Proyek** (biru), **Tambah Proyek** (hijau), **Tambah Pengalaman** (ungu), dan **Logout** (merah).
- `SnackBar` bertuliskan "Kamu telah menekan tombol [Nama Tombol]!" saat tombol ditekan.
- Drawer yang sama di semua halaman dengan opsi **Home**, **Add Project**, dan **Add Experience**.
- Formulir proyek dan formulir pengalaman dengan validasi dan dialog ringkasan.
- **Fitur tambahan Tugas 8:** dialog "Buang perubahan?" saat pengguna meninggalkan formulir proyek atau pengalaman yang belum disimpan, baik lewat tombol kembali maupun opsi drawer.

### Aturan Formulir Pengalaman

Field mengikuti model Django `Experience` pada proyek web portofolio.

| Field model | Input | Aturan |
| --- | --- | --- |
| `title` | `TextFormField` | Wajib, tidak boleh hanya spasi, maksimal 255 karakter |
| `description` | `TextFormField` multiline | Wajib, tidak boleh hanya spasi |
| `category` | `DropdownButtonFormField` | Salah satu dari 7 pilihan model, default Full-Time |
| `thumbnail` | `TextFormField` | Opsional, harus URL `http`/`https` dengan domain, maksimal 200 karakter |
| `started_at` | Tampilan terkunci | Otomatis hari ini karena model memakai `auto_now_add` |
| `ended_at` | `showDatePicker()` | Opsional, tidak boleh sebelum tanggal mulai, kosong berarti masih berlangsung |

## Struktur Proyek

- `lib/main.dart`: titik masuk aplikasi dan `MaterialApp` (tema dan halaman awal).
- `lib/screens/menu.dart`: `MyHomePage`, `InfoCard`, dan model `ItemHomepage` (nama, ikon, warna).
- `lib/screens/project_form.dart`: formulir tambah proyek.
- `lib/screens/experience_form.dart`: formulir tambah pengalaman.
- `lib/validators/experience_validators.dart`: aturan validasi formulir pengalaman.
- `lib/widgets/left_drawer.dart`: drawer navigasi yang dipakai bersama.
- `lib/widgets/project_card.dart`: `ItemCard` untuk tombol aksi.
- `lib/widgets/unsaved_changes_scope.dart`: dialog dan pengaman keluar yang dipakai kedua formulir.
- `test/widget_test.dart`: widget test untuk halaman utama.
- `test/experience_form_test.dart`: test navigasi, validasi, dialog, dan layar sempit pada formulir pengalaman.
- `test/project_form_test.dart`: test konfirmasi keluar dan reset pada formulir proyek.

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
- **Tutorial 09**: formulir Tambah Proyek, drawer navigasi, dan pemisahan kode ke `lib/screens/` serta `lib/widgets/`.
- **Tugas 8**: formulir Pengalaman sesuai model `Experience` dengan validasi dan dialog ringkasan, kartu aksi dan opsi drawer baru, tata letak halaman utama yang aman di layar ponsel, serta konfirmasi sebelum meninggalkan formulir yang belum disimpan.

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

### Tugas 8

1. Yap, aku pake `Navigator.push()` buat buka page `form` baru tanpa ngehapus `main page` sebelumnya, jadi user masih bisa balik ke `main page` pake button `back`. Truss jugak, `Navigator.pushReplacement()` aku pake di menu `Home` di drawer buat ngeganti page yang lagi dibuka bareng `main page`. Dengan begitu, navigasi `antarhalaman` bisa jalan sesuai kebutuhan.

2. Aku pake `Scaffold` sebagai kerangka dasar setiap page supaya posisi `AppBar`, `Drawer`, dan `Body` tetap konsisten. Teruss, aku bikin `LeftDrawer` secara terpisah supaya bisa dipake lagi di `main page` maupun page form tanpa harus rewrite kodenya. Aku juga pake `Theme.of(context).colorScheme.primary` biar warna `AppBar` ngikutin tema aplikasi, jadi pas warna tema diubah, tampilannya ikut nyesuai-in.

3. Aku nyusun `form` pake `Column` karna menurutku susunan input yang vertikal itu kaya lebih mudah dipake, apalagi di layar `mobile`. Aku juga pake `Padding` ama `spacing` buat ngatur jarak `antar-elemen` biar tampilannya lebih rapi. Trus juga, `SafeArea` dipake supaya konten gak ketutup area sistem, sedangkan `SingleChildScrollView` bikin pengguna tetap ngakses semua input dan button `Simpan` pas ukuran `form` ngelebihin layar, misal pas keyboard muncul.

4. Aku pake `GlobalKey<FormState>` buat nyambungin button `Simpan` dengan state dari `form`, sehingga setiap input bisa di cek pake `validate()`. Di setiap input, aku nambahin `validator` buat mastiin data yang dimasukkin sesuai sama ketentuan. Kalo ada input yang ga valid, massage `error` bakal ditampil-in dan dialog ringkasan gaakan muncul. Contohnya aja pas user masuk-in yg bukan URL pada bagian URL Thumbnail. Aku juga pake `TextInputType.url` buat mempermudah pengguna ngetik URL, tetapi format URL tetep aja perlu di cek pake validator karna user masih bisa masuk-in teks dengan format apa pun.

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

## AI Disclosure Tugas 8

Tugas 8 dikerjakan dengan bantuan Claude Code.

### Cakupan Bantuan AI

- Membaca instruksi tugas, kode proyek mobile, dan model `Experience` di proyek Django.
- Memperbaiki `experience_validators.dart`, dan `experience_form_test.dart` yang sebelumnya error dan berantakan.
- Menambahkan kartu aksi dan opsi drawer, lalu memperbarui test halaman utama.
- Menambahkan konfirmasi keluar di formulir proyek dan pengalaman lewat komponen `UnsavedChangesScope` (berbasis `PopScope`) dan pengaman navigasi pada `LeftDrawer`.

### Keterbatasan AI yang Diidentifikasi

- **AI sempat salah memilih bagian.** Karena belum menemukan proyek Django, AI awalnya membuat formulir Sertifikasi yang tidak ada modelnya. Setelah aku menunjukkan lokasi proyeknya, formulir diganti menjadi Pengalaman sesuai model `Experience`.
- **AI awalnya memasang konfirmasi keluar hanya di formulir pengalaman.** Aku yang menemukan formulir proyek belum punya fitur yang sama.
- **AI belum mencoba aplikasi di emulator atau perangkat Android**, dan papan ketik virtual tidak ikut diuji di browser.
- **Font bawaan `flutter test` berbeda dari font aplikasi**, jadi hasil test layout tetap perlu dicek secara visual.

### Penyesuaian Manual yang Dilakukan

- Menjalankan `flutter analyze`, `flutter test`, dan mencoba alur formulir di browser pada ukuran 360x640.
- Memperbaiki reset formulir proyek agar nilai yang tersimpan di state ikut kosong setelah dialog ditutup.
- Memperbaiki tata letak halaman utama yang meluap di layar ponsel.
- Menulis `experience_form.dart`, `experience_validators.dart`, dan `experience_form_test.dart`