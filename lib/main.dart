import 'package:flutter/material.dart';

import 'pages/school_shell_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const RoseSchoolApp());
}

class RoseSchoolApp extends StatelessWidget {
  const RoseSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rose School',
      theme: buildAppTheme(),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: SchoolShellPage(),
      ),
    );
  }
}
