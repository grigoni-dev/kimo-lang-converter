import 'dart:convert';
import 'dart:io';

import 'localization_dictionary_converter.dart';

void main(List<String> args) {
  final languages = <String>["it", "en", "fr"];
  for (var lang in languages) {
    final sourceFilename = "locale-$lang";

    Future<Map<String, dynamic>> fileFuture = _readJsonFile(sourceFilename);
    fileFuture.then((value) {
      final localizator = LocalizationDictionaryConverter(source: value, sourceFilename: sourceFilename, lang: lang);
      localizator.converter();
    });
  }
}

Future<Map<String, dynamic>> _readJsonFile(String sourceFilename) async {
  final file = File('bin/assets/input/$sourceFilename.json');
  final content = await file.readAsString();
  final instance = jsonDecode(content);
  return instance;
}
