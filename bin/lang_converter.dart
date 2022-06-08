import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'localization_dictionary_converter.dart';

void main(List<String> args) {
  final lang = "fr";
  final sourceFilename = "locale-$lang";

  convertJsonFileToFlat(sourceFilename, lang);
}

void convertJsonFileToFlat(sourceFilename, lang) {
  Future<Map<String, dynamic>> fileFuture = _readJsonFile(sourceFilename);
  fileFuture.then((source) {
    final result = SplayTreeMap<String, String>((a, b) => a.compareTo(b));
    LocalizationDictionaryConverter.convertAndCreate(source, result, lang);
  });
}

void compareGeneratedMapsAndUpdate(sourceFilename, lang) {
  Future<Map<String, dynamic>> fileFuture = _readJsonFile(sourceFilename);
  fileFuture.then((source) {
    final result = SplayTreeMap<String, String>((a, b) => a.compareTo(b));
    LocalizationDictionaryConverter.convertAndCreate(source, result, lang);
  });
}

void converterCompareAndUpdate(sourceFilename, lang) {
  Future<Map<String, dynamic>> fileFuture = _readJsonFile(sourceFilename);
  fileFuture.then((source) {
    LocalizationDictionaryConverter.converterCompareAndUpdate(source, sourceFilename, lang);
    final result = SplayTreeMap<String, String>((a, b) => a.compareTo(b));
    LocalizationDictionaryConverter.convertAndCreate(source, result, lang);
  });
}

void getFilesInDirectory() async {
  final myDir = Directory('bin/assets/input');
  var isThere = await myDir.exists();
  print(isThere ? 'exists' : 'non-existent');
}

Future<Map<String, dynamic>> _readJsonFile(String filenameServer) async {
  final file = File('bin/assets/input$filenameServer.json');
  final content = await file.readAsString();
  final instance = jsonDecode(content);
  return instance;
}
