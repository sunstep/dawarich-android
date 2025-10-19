

import 'dart:io' show Platform;

import 'package:sqlite3/open.dart' as sqlite3;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';


final class SqlcipherBootstrap {

  static Future<void> ensure() async {

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      sqlite3.open.overrideFor(sqlite3.OperatingSystem.android, openCipherOnAndroid);
    }

  }
}
