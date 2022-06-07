import 'dart:convert';
import 'dart:io';

import 'localization_dictionary_converter.dart';

void main(List<String> args) {
  final lang = "fr";
  final sourceFilename = "locale-$lang";

  Future<Map<String, dynamic>> fileFuture = _readJsonFile(sourceFilename);
  fileFuture.then((value) {
    final localizator = LocalizationDictionaryConverter(source: value, sourceFilename: sourceFilename, lang: lang);
    localizator.converter();
  });
}

Future<Map<String, dynamic>> _readJsonFile(String filenameServer) async {
  final file = File('bin/assets/$filenameServer.json');
  final content = await file.readAsString();
  final instance = jsonDecode(content);
  return instance;
}
