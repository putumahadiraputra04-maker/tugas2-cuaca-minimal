import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'views/home_page.dart';

void main() => runApp(const CuacaApp());

class CuacaApp extends StatelessWidget {
  const CuacaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuaca Minimal',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomePage(),
    );
  }
}
