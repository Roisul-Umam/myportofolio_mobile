import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = '2506620210';
  final String name = 'Roisul Umam';
  final String className = 'PBP F';

  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Proyek", Icons.folder_open, Colors.blue),
    ItemHomepage("Tambah Proyek", Icons.add, Colors.green),
    ItemHomepage("Tambah Pengalaman", Icons.work_outline, Colors.deepPurple),
    ItemHomepage("Logout", Icons.logout, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Portfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: InfoCard(title: 'NPM', content: npm)),
                Expanded(child: InfoCard(title: 'Name', content: name)),
                Expanded(child: InfoCard(title: 'Class', content: className)),
              ],
            ),
            const SizedBox(height: 16.0),
            const Center(
              child: Text(
                'Welcome to My Portfolio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              // Dua kolom di ponsel supaya label kartu tetap terbaca.
              crossAxisCount: MediaQuery.sizeOf(context).width < 480 ? 2 : 3,
              shrinkWrap: true,
              children: items.map((ItemHomepage item) => ItemCard(item)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8.0),
            FittedBox(fit: BoxFit.scaleDown, child: Text(content)),
          ],
        ),
      ),
    );
  }
}