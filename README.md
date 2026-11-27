# MyPortfolio Mobile

[![CI](https://github.com/Roisul-Umam/myportofolio_mobile/actions/workflows/main.yaml/badge.svg)](https://github.com/Roisul-Umam/myportofolio_mobile/actions/workflows/main.yaml)

Aplikasi mobile Flutter untuk portofolio saya (Roisul Umam).

## Fitur Saat Ini

- **Halaman utama** dengan sapaan, pencarian, chip tag, banner identitas (NPM, Name, Class), aksi cepat, carousel proyek unggulan, dan bottom navigation.
- **5 tombol aksi** `ItemCard` dengan warna berbeda: **Lihat Proyek**, **Tambah Proyek**, **Lihat Pengalaman**, **Tambah Pengalaman**, dan **Logout**. Setiap tombol menampilkan `SnackBar`.
- **Proyek (Tutorial 10)**: daftar dan detail dari `GET /api/v1/projects/`, serta form tambah proyek yang mengirim `POST` dengan token.
- **Pengalaman (Assignment 9)**: daftar publik dari `GET /api/v1/experience/` (loading, error + Retry, kosong, pull-to-refresh, filter kategori, pencarian), detail berisi seluruh field, form tambah dengan `POST` terautentikasi, dan **hapus (`DELETE`) terautentikasi** dengan dialog konfirmasi.
- **Autentikasi token**: layar login, `ensureLoggedIn` untuk aksi tulis, opsi Login/Logout di drawer, dan penanganan 401 (sesi dihapus, login ulang, lalu request diulang sekali).
- Drawer yang sama di semua halaman: **Home**, **Projects**, **Add Project**, **Experiences**, **Add Experience**, dan **Login/Logout**.
- **Fitur tambahan Tugas 8:** dialog "Buang perubahan?" saat pengguna meninggalkan formulir proyek atau pengalaman yang belum disimpan, baik lewat tombol kembali maupun opsi drawer.

### Aturan Formulir Pengalaman

Field mengikuti model dan `ExperienceSerializer` Django.

| Field model | Input | Aturan |
| --- | --- | --- |
| `title` | `TextFormField` | Wajib, tidak boleh hanya spasi, maksimal 255 karakter |
| `description` | `TextFormField` multiline | Wajib, tidak boleh hanya spasi |
| `category` | `DropdownButtonFormField` | Salah satu dari 7 pilihan model, default Full-Time |
| `thumbnail` | `TextFormField` | Opsional, harus URL `http`/`https` dengan domain, maksimal 200 karakter |
| `started_at` | Tampilan terkunci | Diisi server (`auto_now_add`), jadi tidak dikirim |
| `ended_at` | `showDatePicker()` | Opsional, tidak boleh sebelum hari ini, dikirim sebagai akhir hari dalam UTC |

## Struktur Proyek

- `lib/main.dart`: `MaterialApp` dan `MultiProvider` yang menyediakan `ApiClient` serta `AuthState`.
- `lib/config.dart`: `apiBaseUrl` yang otomatis memilih URL sesuai platform, dan bisa ditimpa dengan `--dart-define=API_BASE_URL`.
- `lib/models/`: `Project` dan `Experience` dengan `@JsonSerializable` (file `*.g.dart` dibuat `build_runner` dan tidak di-commit).
- `lib/services/api_client.dart`: GET/POST proyek, GET/POST/DELETE pengalaman, login, dan logout; status non-2xx dilempar sebagai `ApiException`.
- `lib/services/auth_state.dart`: token sesi di memori (`ChangeNotifier`).
- `lib/screens/`: halaman utama, login, daftar/detail/form proyek, serta daftar/detail/form pengalaman.
- `lib/widgets/`: drawer, kartu aksi, kartu proyek/pengalaman, lembar akun, `ensureLoggedIn`, `runWithRelogin`, dan `UnsavedChangesScope`.
- `lib/validators/`: aturan validasi form proyek dan pengalaman.
- `lib/theme/app_theme.dart`: tema global.
- `test/`: unit test `MockClient` untuk `ApiClient` dan model, test `AuthState`, serta widget test untuk alur login, daftar, detail, form, dan hapus.
- `.github/workflows/main.yaml`: CI (`very_good_workflows`) dan build APK release.

## Cara Menjalankan

Backend Django ada di repositori terpisah: <https://github.com/Roisul-Umam/myportofolio>. Asisten dosen bisa menjalankannya secara lokal untuk memverifikasi integrasi end-to-end.

### 1. Backend Django

```bash
git clone https://github.com/Roisul-Umam/myportofolio.git
cd myportofolio
python -m venv venv
venv\Scripts\activate        # Windows; di macOS/Linux: source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser   # hanya superuser yang boleh menambah/menghapus data
python manage.py runserver
```

Endpoint yang dipakai aplikasi:

| Metode | Path | Autentikasi |
| --- | --- | --- |
| `GET` | `/api/v1/projects/`, `/api/v1/experience/` | Publik |
| `POST` | `/api/v1/projects/`, `/api/v1/experience/` | `Authorization: Token <key>` |
| `DELETE` | `/api/v1/experience/<uuid>/` | `Authorization: Token <key>` |
| `POST` | `/api/v1/auth/token/` | Publik (username + password) |
| `POST` | `/api/v1/auth/logout/` | `Authorization: Token <key>` |

### 2. Aplikasi Flutter

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # membuat lib/models/*.g.dart
```

Aplikasi otomatis memilih URL backend sesuai tempat ia berjalan, jadi bisa langsung dijalankan dari web maupun emulator tanpa argumen tambahan:

| Tempat berjalan | URL bawaan | Perintah |
| --- | --- | --- |
| Chrome / web | `http://localhost:8000` | `flutter run -d chrome` |
| Emulator Android | `http://10.0.2.2:8000` (alamat laptop dari dalam emulator) | `flutter run`, atau tombol Run di Android Studio |
| Desktop / simulator iOS | `http://localhost:8000` | `flutter run -d windows` (atau perangkat lain) |

`10.0.2.2` sudah terdaftar di `ALLOWED_HOSTS` backend. URL bawaan tetap bisa ditimpa dengan `--dart-define=API_BASE_URL=...`, misalnya:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Untuk HP Android fisik, jalankan backend dengan `python manage.py runserver 0.0.0.0:8000`, tambahkan IP laptop ke `ALLOWED_HOSTS`, lalu jalankan aplikasi dengan `--dart-define=API_BASE_URL=http://<ip-laptop>:8000`. Di Android Studio, argumen ini diisi di **Run → Edit Configurations → Additional run args**.

### 3. Pemeriksaan kualitas

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Progres Mingguan

- **Tutorial 08**: setup Flutter, memisahkan `menu.dart` dari `main.dart`, `MyHomePage` menjadi `StatelessWidget`, dan membuat `InfoCard` serta `ItemCard`.
- **Tugas 7**: identitas pemilik portofolio, 3 tombol aksi dengan warna berbeda lewat atribut `color` di `ItemHomepage`, SnackBar interaktif, dan `flutter analyze` bersih.
- **Tutorial 09**: formulir Tambah Proyek, drawer navigasi, dan pemisahan kode ke `lib/screens/` serta `lib/widgets/`.
- **Tugas 8**: formulir Pengalaman sesuai model `Experience` dengan validasi dan dialog ringkasan, kartu aksi dan opsi drawer baru, tata letak halaman utama yang aman di layar ponsel, serta konfirmasi sebelum meninggalkan formulir yang belum disimpan.
- **Tutorial 10**: model `Project` dengan `json_serializable`, `ApiClient`, daftar dan detail proyek dengan `FutureBuilder`, autentikasi token (`AuthState`, login, `ensureLoggedIn`), form proyek yang mengirim `POST`, CI/CD GitHub Actions, dan desain ulang tampilan aplikasi.
- **Assignment 9**: integrasi bagian Pengalaman dengan endpoint DRF (`GET` publik, `POST` dan `DELETE` dengan token), layar daftar dan detail, form yang dijaga login, penanganan 401, badge CI, serta unit test `MockClient`.

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

### Assignment 9

1. Pake `@JsonSerializable(fieldRename: FieldRename.snake)` buat mapping nama field Dart kayak `categoryDisplay` dan `endedAt` ke kunci JSON DRF kayak `category_display` dan `ended_at` secara otomatis. Trus, kode konversinya dibikin pake `build_runner`, jadi aku ga perlu nulis proses konversi secara manual di setiap widget. Dengan begitu, data dari server bisa langsung diubah jadi objek `Experience` yang punya tipe data jelas. Aku juga pake `@JsonKey(includeToJson: false)` buat mastiin field yang asalnya dari server kayak `id`, `started_at`, `category_display`, `is_ongoing`, dan `star_count` gaikut dikirim pas POST. Contohnya, kalo body `POST` dibikin manual pake Map dan aku salah nulis key `'endedAt'`, DRF bisa aja `ngabai-in` key-nya tanpa error, sehingga pengalaman ke-save tanpa tanggal selesai dan dianggap masih berlangsung. Selain itu, aku pake `@JsonKey(defaultValue: '')` buat nanganin `thumbnail` yang bisa bernilai `null` dari server, supaya proses pembacaan data ga nyebabin `TypeError` dan bikin seluruh daftar gagal buat dishow.

2. `build()` bisa call berkali-kali, misal pas `setState`, ukuran layar berubah, keyboard muncul, atau pas parent di-rebuild. Kalau `getExperiences()` dipanggil di dalam `build()`, setiap rebuild bikin `Future` baru, makanya request GET di re-send terus-terusan dan `FutureBuilder` balik ke loading display, malahan bisa berputar tanpa henti. Bikin `Future` sekali di `initState()` dan ngegantinya cuma pas refresh atau Retry bikin request berlangsung tepat pas dibutuhin. `ApiClient` ngelempar `ApiException` karna `null` gabisa ngebedain "data kosong" dari "request gagal", dan kode status-nya ilang. Kalo sama exception, `FutureBuilder` otomatis masuk ke `snapshot.hasError` dan nampilin message serta button Retry. Caller juga bisa ngerespons sesuai status: 401 berarti hapus sesi trus login ulang, 403 berarti nampilin pesan gapunya izin, dan 500 berarti servernye ada masalah. Tipe return pun tetep `Future<List<Experience>>` tanpa `null` yang harus dicek di mana-mana.

3. `SessionAuthentication` nyimpen sesi di server dan ngenalin user lewat cookie `sessionid`. Karna cookie disend otomatis oleh browser, jadi setiap request tulis wajib bawa token CSRF. Cara inituh cocok buat page web Django yang dirender di browser yang sama. `TokenAuthentication` sifatnya stateless: klien nyimpen token sendiri dan ngirimin lewat header `Authorization: Token <key>`, tanpa cookie dan CSRF, sehingga cocok buat aplikasi mobile yang gapunya pengelolaan cookie kayak browser. Token juga bisa dicabut kapan aja, misal pas logout or lewat Django Admin, dan aplikasi langsung dapet 401. `myportofolio_mobile` pake token karena alasan itu, sedangkan `SessionAuthentication` tetap aktif karna page web (termasuk `experience.html` yang ngecall API dari JavaScript), Browsable API, dan Django Admin tetep pake login session. Di settings, `TokenAuthentication` sengaja ditaro paling awal supaya request tanpa kredensial atau bareng token yang gak valid dijawab 401 sama header `WWW-Authenticate`, bukan 403. Dari situlah aplikasi tau kapan harus minta re-login.

4. Di bagian `CI/CD`, aku pake job build yang manggil workflow `flutter_package.yml` dari `very_good_workflows`. Di tahap setup, aku ngenjalanin `build_runner` dulu, baru workflow bakal masang `dependencies`, meriksa format kode pake dart format `--set-exit-if-changed`, ngenjalanin flutter analyze, dan ngelakuin testing pake flutter test dengan coverage. Aku juga ngatur `min_coverage` menjadi 0 dan ngecualiin file `*.g.dart` dari perhitungan coverage. Setelah job build berhasil, job `build_apk` baru dijalanin karena pake needs: build. Job ini tugasnya itu nyiapin Flutter, masang `dependencies`, ngejalanin `build_runner`, lalu bikin `APK` pake `flutter build apk --release`. Hasilnya kemudian diupload sebagai artefak `app-release-apk` yang bisa didownload lewat `GitHub Actions`. Aku juga masukin file `*.g.dart` ke `.gitignore` karna file itu-tuh file hasil generate dari `project.dart` sama `experience.dart`. Jadi, aku ga perlu commit file hasil generate yang bisa aja sudah kadaluarsa pas model diubah, sekaligus ngindarin konflik merge yang ga perlu.

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

## AI Disclosure Assignment 9

Tugas 9 dikerjakan dengan bantuan Claude Code.

### Cakupan Bantuan AI

- Menyesuaikan test backend (tamu yang belum login sekarang mendapat 401), menambah validasi `ended_at` saat membuat data, dan menambah test `POST`/`DELETE` dengan token.
- Menyesuaikan metode `ApiClient` untuk Experience, helper `runWithRelogin`, layar daftar dan detail dan fitur hapus.
- Memperbaiki test Flutter (`experience_api_test.dart`, `experience_list_screen_test.dart`, dan menulis ulang `experience_form_test.dart`).

### Keterbatasan AI yang Diidentifikasi

- **AI tidak bisa memastikan workflow GitHub Actions hijau** karena belum ada push. Build APK juga gagal dijalankan di lingkungan AI karena Gradle diblokir sandbox, jadi job `build_apk` baru terbukti setelah push.
- **AI belum menguji di emulator atau perangkat Android.** Pengujian hanya di Chrome. `ALLOWED_HOSTS` Django juga awalnya belum memuat `10.0.2.2` sehingga emulator akan ditolak 400; AI menambahkannya setelah aku bertanya cara menjalankan di Android Studio. URL backend juga awalnya selalu `10.0.2.2` kecuali diberi `--dart-define`, sehingga aplikasi gagal terhubung saat aku menjalankannya di browser dari Android Studio; AI lalu membuat URL-nya otomatis menyesuaikan platform.
- **AI sempat membuat label kartu aksi terpotong** ("Pengalam…") setelah menambah kartu kelima, dan baru ketahuan saat dicek di browser.
- **Kode hasil generate sempat salah**: nilai bawaan `category` awalnya ditulis tanpa nama kelas sehingga tidak dikenali di `experience.g.dart`, lalu diperbaiki menjadi `Experience.defaultCategory`.

### Penyesuaian Manual yang Dilakukan

- Menyelesaikan konflik merge `feat/api` dengan perubahan token auth Tutorial 10, termasuk menghapus
`@authentication_classes([SessionAuthentication])` di view Experience supaya token diterima.
- Menulis model `Experience`, metode `ApiClient` untuk Experience, layar daftar, fitur hapus, serta mengubah form Pengalaman agar mengirim `POST`.
- Menguji alur end-to-end di Chrome terhadap salinan server Django, termasuk skenario 401 dengan menghapus token lewat Django shell.