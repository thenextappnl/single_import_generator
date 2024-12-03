import 'dart:io';

import 'package:path/path.dart';

void generateImportsForAllFiles(String targetPath, String filename) {
  final directory = Directory(targetPath);
  final fileList = directory.listSync(recursive: true, followLinks: false);

  //sort files in directory as last
  fileList.sort((a, b) {
    String aDirName = dirname(a.path).replaceAll(targetPath, '');
    String bDirName = dirname(b.path).replaceAll(targetPath, '');

    if(aDirName == bDirName) {
      return a.path.compareTo(b.path);
    }

    if(aDirName.isEmpty && bDirName.isNotEmpty) {
      return 1;
    }
    if(aDirName.isNotEmpty && bDirName.isEmpty) {
      return -1;
    }

    return aDirName.compareTo(bDirName);
  });

  final exportStatements = <String>{};

  for (var entity in fileList) {
    if (entity is File &&
        entity.path.endsWith('.dart') &&
        !entity.path.endsWith('.freezed.dart') &&
        !entity.path.endsWith('.g.dart') &&
        !entity.path.endsWith('.chopper.dart') &&
        !entity.path.endsWith('.gr.dart') &&
        !entity.path.endsWith('$filename.barrel.dart')) {
      final relativePath = entity.path.substring(directory.path.length + 1);
      final exportStatement = "export './$relativePath';";

      exportStatements.add(exportStatement);
    }
  }

  String indexFileContent = '//GENERATED BARREL FILE\n';
  indexFileContent += exportStatements.join('\n');

  final indexPath = '$targetPath/$filename.barrel.dart';

  File(indexPath).writeAsStringSync(indexFileContent);

  final numExportsAdded = exportStatements.length;
  print(
      'Index file generated successfully at: $indexPath [$numExportsAdded export file(s) added]');
}