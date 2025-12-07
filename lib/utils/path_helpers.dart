import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<String> getDatabasePath() async {
  // Finds the standard writable directory for the application's persistent files.
  final directory = await getApplicationDocumentsDirectory();
  // Safely joins the directory path with the filename.
  final dbPath = p.join(directory.path, 'vault.db'); 
  return dbPath;
}