import 'package:flutter/material.dart';
import 'package:tengoku/src/ui/theme/global.dart';
import 'package:tengoku/src/ui/views/root_view.dart';

void main() {
  const app = Application();
  runApp(app);
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeMode.system,
      home: const RootView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
