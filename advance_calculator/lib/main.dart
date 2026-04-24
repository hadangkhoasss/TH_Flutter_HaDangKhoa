import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/calculator_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/history_provider.dart';
import 'services/storage_service.dart';
import 'utils/expression_parser.dart';
import 'screens/calculator_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final parser = ExpressionParser();
  runApp(MyApp(storage: storage, parser: parser));
}

class MyApp extends StatelessWidget {
  final StorageService storage;
  final ExpressionParser parser;
  const MyApp({Key? key, required this.storage, required this.parser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => HistoryProvider(storage)),
        ChangeNotifierProvider(create: (_) => CalculatorProvider(storage: storage, parser: parser)),
      ],
      child: Consumer<ThemeProvider>(builder: (context, themeProv, _) {
        return MaterialApp(
          title: 'Advanced Calculator',
          debugShowCheckedModeBanner: false,
          themeMode: themeProv.themeMode,
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch().copyWith(primary: Colors.blue),
          ),
          darkTheme: ThemeData.dark(),
          initialRoute: '/',
          routes: {
            '/': (_) => CalculatorScreen(),
            '/history': (_) => HistoryScreen(),
            '/settings': (_) => SettingsScreen(),
          },
        );
      }),
    );
  }
}