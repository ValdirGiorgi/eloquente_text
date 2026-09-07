import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_theme/system_theme.dart';

import '../ui/home/home_page.dart';
import 'app_info.dart';

/// Raiz da árvore de widgets: tema claro/escuro do Fluent UI seguindo o
/// sistema, com a cor de destaque do próprio sistema operacional.
class EloquenteTextApp extends StatelessWidget {
  const EloquenteTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = SystemTheme.accentColor.accent.toAccentColor();
    final fontFamily = GoogleFonts.inter().fontFamily;

    return FluentApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData(accentColor: accent, fontFamily: fontFamily),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: accent,
        fontFamily: fontFamily,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
