import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const bg = Color(0xFF090B14);
const panel = Color(0xFF151A2A);
const cyan = Color(0xFF42E8F5);
const violet = Color(0xFF9272FF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var connected = false;
  try {
    await dotenv.load(fileName: '.env');
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    if (url.startsWith('https://') && key.isNotEmpty) {
      await Supabase.initialize(url: url, anonKey: key);
      connected = true;
    }
  } catch (_) {
    // The preview UI remains usable until Supabase is configured.
  }
  runApp(NexusApp(backendConfigured: connected));
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key, required this.backendConfigured});
  final bool backendConfigured;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'NEXUS',
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: cyan, secondary: violet, surface: panel),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: panel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    ),
    home: HomePage(backendConfigured: backendConfigured),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.backendConfigured});
  final bool backendConfigured;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  final groups = const [
    ('VALORANT HUB', 'تكتيكات • مباريات • دردشة', Icons.gps_fixed, cyan),
    ('MINECRAFT WORLD', 'بناء • سيرفرات • فعاليات', Icons.cube_outlined, violet),
    ('FORTNITE SQUAD', 'بحث عن فريق • تحديات', Icons.sports_esports, Color(0xFFFF65B5)),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Row(children: [
      NavigationRail(
        backgroundColor: const Color(0xFF0D1120),
        selectedIndex: selected,
        onDestinationSelected: (v) => setState(() => selected = v),
        labelType: NavigationRailLabelType.all,
        destinations: const [
          NavigationRailDestination(icon: Icon(Icons.hub_outlined), selectedIcon: Icon(Icons.hub), label: Text('المجتمعات')),
          NavigationRailDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: Text('اكتشف')),
          NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('حسابي')),
        ],
      ),
      Expanded(child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(gradient: const LinearGradient(colors: [cyan, violet]), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.bolt, color: bg)),
              const SizedBox(width: 12),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('NEXUS', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: 2)), Text('YOUR GAME. YOUR COMMUNITY.', style: TextStyle(fontSize: 9, color: cyan, letterSpacing: 1.2))]),
            ]),
            const SizedBox(height: 25),
            const Text('مرحباً بك في مجتمعك', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            const SizedBox(height: 7),
            Text(widget.backendConfigured ? 'اتصال Supabase مضبوط مبدئياً' : 'واجهة المعاينة جاهزة — اربط Supabase لتفعيل الحسابات والمجتمعات.', style: const TextStyle(color: Colors.white60, height: 1.5)),
            const SizedBox(height: 18),
            TextField(decoration: InputDecoration(hintText: 'ابحث عن مجتمع أو لعبة...', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: _createGroupInfo, icon: const Icon(Icons.add_circle, color: cyan)))),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('مجتمعاتك', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), TextButton.icon(onPressed: _createGroupInfo, icon: const Icon(Icons.add), label: const Text('إنشاء مجتمع'))]),
          ]),
        )),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 18), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, i) {
          final g = groups[i];
          return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: .06))), child: ListTile(contentPadding: const EdgeInsets.all(14), leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: g.$4.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)), child: Icon(g.$3, color: g.$4)), title: Text(g.$1, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(g.$2, style: const TextStyle(color: Colors.white54))), trailing: const Icon(Icons.chevron_right, color: Colors.white38), onTap: () => _showGroup(g.$1)));
        }, childCount: groups.length))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF20264A), Color(0xFF171A30)]), borderRadius: BorderRadius.circular(18)), child: const Row(children: [Icon(Icons.mic, color: cyan, size: 30), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('الغرف الصوتية قادمة', style: TextStyle(fontWeight: FontWeight.bold)), Text('سيتم تفعيل الصوت والفيديو بعد إعداد LiveKit والخادم الآمن.', style: TextStyle(color: Colors.white60, fontSize: 12))]))])))),
      ])),
    ])),
  );

  void _createGroupInfo() => showDialog<void>(context: context, builder: (c) => AlertDialog(backgroundColor: panel, title: const Text('إنشاء مجتمع'), content: const Text('سيتم تفعيل إنشاء المجتمعات وربطها بقاعدة البيانات في المرحلة التالية بعد إعداد Supabase.'), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('حسناً'))]));
  void _showGroup(String name) => showModalBottomSheet<void>(context: context, backgroundColor: panel, builder: (c) => Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 12), const Text('قنوات المجتمع ستظهر هنا بعد ربط قاعدة البيانات.'), const SizedBox(height: 18), const ListTile(leading: Icon(Icons.tag, color: cyan), title: Text('general')), const ListTile(leading: Icon(Icons.forum_outlined, color: violet), title: Text('chat'))])));
}
