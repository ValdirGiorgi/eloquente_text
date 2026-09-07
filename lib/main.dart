import 'package:fluent_ui/fluent_ui.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const EloquenteTextApp());
}
