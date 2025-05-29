import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'Widgets/history_entry.dart';
import 'Pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializa o Hive
  await Hive.initFlutter();

  // ✅ Registra o adapter
  Hive.registerAdapter(HistoryEntryAdapter());

  // ✅ Abre a box de histórico
  await Hive.openBox<HistoryEntry>('history');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lens Chat AI',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
