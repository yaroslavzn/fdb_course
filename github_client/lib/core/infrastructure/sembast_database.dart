import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class SembastDatabase {
  late Database _instance;
  Database get instance => _instance;

  bool _hasBeenInitialized = false;

  Future<void> init() async {
    if (_hasBeenInitialized) return;
    _hasBeenInitialized = true;

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    appDocDir.create(recursive: true);
    final dbPath = join(appDocDir.path, 'db.application');
    _instance = await databaseFactoryIo.openDatabase(dbPath);
  }
}
